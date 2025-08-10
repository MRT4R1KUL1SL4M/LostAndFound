from flask import Flask, render_template, request, redirect, url_for, session, flash
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text
from werkzeug.security import generate_password_hash, check_password_hash
import os
from werkzeug.utils import secure_filename
from functools import wraps
import random
from datetime import datetime, timedelta, timezone
from flask_mail import Mail, Message
from PIL import Image
import disposable_email_domains # <-- NEW: Import the library

# --- App Initialization ---
app = Flask(__name__)

# --- Configuration ---
app.config.from_pyfile('config.py')

# --- Image Upload Configuration ---
UPLOAD_FOLDER = 'static/uploads'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# Initialize Services
db = SQLAlchemy(app)
mail = Mail(app)

# --- Custom Template Filter for Timezone Conversion ---
@app.template_filter('bst')
def format_to_bst(utc_dt):
    if utc_dt is None:
        return ""
    bst = timezone(timedelta(hours=6))
    if utc_dt.tzinfo is None:
        utc_dt = utc_dt.replace(tzinfo=timezone.utc)
    bst_dt = utc_dt.astimezone(bst)
    return bst_dt.strftime('%d %b %Y, %I:%M %p')

# --- Helper Functions & Decorators ---
def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            flash('Please log in to access this page.', 'warning')
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

def admin_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session or session.get('role') != 'admin':
            flash('You do not have permission to access this page.', 'danger')
            return redirect(url_for('index'))
        return f(*args, **kwargs)
    return decorated_function

def get_user_role(user_id):
    query = text("SELECT r.role_name FROM roles r JOIN user_roles ur ON r.id = ur.role_id WHERE ur.user_id = :user_id")
    result = db.session.execute(query, {'user_id': user_id}).fetchone()
    return result.role_name if result else 'user'

def get_common_data():
    categories = db.session.execute(text("SELECT * FROM categories ORDER BY name")).fetchall()
    locations = db.session.execute(text("SELECT * FROM locations ORDER BY name")).fetchall()
    return categories, locations

def log_audit(action, target_type=None, target_id=None):
    admin_id = session.get('user_id')
    if admin_id:
        query = text("""
            INSERT INTO audit_logs (admin_id, action, target_type, target_id)
            VALUES (:admin_id, :action, :target_type, :target_id)
        """)
        db.session.execute(query, {'admin_id': admin_id, 'action': action, 'target_type': target_type, 'target_id': target_id})
        db.session.commit()

def create_notification(user_id, message, link):
    try:
        query = text("INSERT INTO notifications (user_id, message, link) VALUES (:user_id, :message, :link)")
        db.session.execute(query, {'user_id': user_id, 'message': message, 'link': link})
        db.session.commit()
    except Exception as e:
        print(f"Error creating notification: {e}")
        db.session.rollback()

def check_for_matches_and_notify(found_item):
    alert_query = text("""
        SELECT * FROM lost_item_alerts 
        WHERE category_id = :category_id AND is_active = TRUE AND user_id != :reporter_id
    """)
    alerts = db.session.execute(alert_query, {
        'category_id': found_item['category_id'],
        'reporter_id': found_item['user_id']
    }).fetchall()
    found_title_words = set(found_item['title'].lower().split())
    for alert in alerts:
        alert_title_words = set(alert.title.lower().split())
        if found_title_words.intersection(alert_title_words):
            message = f"An item matching your alert '{alert.title}' has been found: '{found_item['title']}'. Check it out!"
            link = url_for('item_details', item_id=found_item['id'])
            create_notification(user_id=alert.user_id, message=message, link=link)

@app.context_processor
def inject_notifications():
    if 'user_id' in session:
        user_id = session['user_id']
        query = text("SELECT * FROM notifications WHERE user_id = :user_id ORDER BY created_at DESC LIMIT 5")
        notifications = db.session.execute(query, {'user_id': user_id}).fetchall()
        count_query = text("SELECT COUNT(id) FROM notifications WHERE user_id = :user_id AND is_read = FALSE")
        unread_count = db.session.execute(count_query, {'user_id': user_id}).scalar_one()
        return dict(notifications=notifications, unread_count=unread_count)
    return dict(notifications=[], unread_count=0)


# --- Main Public Routes ---
@app.route('/')
def index():
    announcement_query = text("SELECT * FROM announcements WHERE is_active = TRUE ORDER BY created_at DESC LIMIT 1")
    announcement = db.session.execute(announcement_query).fetchone()

    query = text("""
        SELECT 
            i.id, i.title, i.item_type, i.description, i.reported_at, 
            i.category_id, i.location_id,
            u.full_name, c.name as category_name, l.name as location_name,
            (SELECT image_url FROM item_images WHERE item_id = i.id ORDER BY id LIMIT 1) as main_image
        FROM items i
        JOIN users u ON i.user_id = u.id
        JOIN categories c ON i.category_id = c.id
        JOIN locations l ON i.location_id = l.id
        WHERE i.status = 'reported'
        ORDER BY i.reported_at DESC
    """)
    items = db.session.execute(query).fetchall()
    
    categories, locations = get_common_data()
    
    return render_template('index.html', items=items, categories=categories, locations=locations, announcement=announcement)


@app.route('/item/<int:item_id>')
def item_details(item_id):
    item_query = text("""
        SELECT i.*, u.id as user_id, u.full_name, u.email, u.contact_info, c.name as category_name, l.name as location_name
        FROM items i
        JOIN users u ON i.user_id = u.id
        JOIN categories c ON i.category_id = c.id
        JOIN locations l ON i.location_id = l.id
        WHERE i.id = :item_id
    """)
    item_result = db.session.execute(item_query, {'item_id': item_id}).fetchone()
    
    if not item_result:
        flash('Item not found.', 'danger')
        return redirect(url_for('index'))

    item = dict(item_result._mapping)

    images = db.session.execute(text("SELECT image_url FROM item_images WHERE item_id = :item_id"), {'item_id': item_id}).fetchall()
    item['images'] = images

    tags = db.session.execute(text("SELECT t.name FROM tags t JOIN item_tags it ON t.id = it.tag_id WHERE it.item_id = :item_id"), {'item_id': item_id}).fetchall()
    item['tags'] = tags

    user_claim_status = None
    approved_claim_id = None
    if 'user_id' in session:
        claim_query = text("SELECT id, status FROM claims WHERE item_id = :item_id AND claimant_user_id = :user_id")
        claim = db.session.execute(claim_query, {'item_id': item_id, 'user_id': session['user_id']}).fetchone()
        if claim:
            user_claim_status = claim.status
            if claim.status == 'approved':
                approved_claim_id = claim.id
            
    return render_template('item_details.html', item=item, user_claim_status=user_claim_status, approved_claim_id=approved_claim_id)

@app.route('/announcements')
def all_announcements():
    query = text("SELECT a.*, u.full_name as admin_name FROM announcements a JOIN users u ON a.admin_id = u.id ORDER BY a.created_at DESC")
    announcements = db.session.execute(query).fetchall()
    return render_template('announcements.html', announcements=announcements)


# --- Authentication Routes ---
@app.route('/login', methods=['GET', 'POST'])
def login():
    if 'logged_in' in session:
        flash('You are already logged in.', 'info')
        if session.get('role') == 'admin':
            return redirect(url_for('admin_dashboard'))
        else:
            return redirect(url_for('dashboard'))

    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        
        query = text("SELECT * FROM users WHERE email = :email")
        user = db.session.execute(query, {'email': email}).fetchone()

        if user and user.status == 'suspended':
            flash('Your account has been suspended. Please contact an administrator.', 'danger')
            return redirect(url_for('login'))

        if user and check_password_hash(user.password_hash, password):
            session['logged_in'] = True
            session['user_id'] = user.id
            session['full_name'] = user.full_name
            session['email'] = user.email
            session['role'] = get_user_role(user.id)
            
            if session['role'] == 'admin':
                return redirect(url_for('admin_dashboard'))
            return redirect(url_for('dashboard'))
        else:
            flash('Invalid credentials. Please check your email and password.', 'danger')
    return render_template('login.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        full_name = request.form['full_name']
        email = request.form['email']
        password = request.form['password']
        confirm_password = request.form['confirm_password']

        # --- NEW: Disposable Email Check ---
        domain = email.split('@')[-1]
        if domain in disposable_email_domains.blacklist:
            flash('Please use a permanent email address. Disposable emails are not allowed.', 'danger')
            return redirect(url_for('register'))

        if password != confirm_password:
            flash('Passwords do not match. Please try again.', 'danger')
            return redirect(url_for('register'))

        existing_user = db.session.execute(text("SELECT id FROM users WHERE email = :email"), {'email': email}).fetchone()

        if existing_user:
            flash('This email address is already registered. Please log in.', 'danger')
            return redirect(url_for('login'))

        password_hash = generate_password_hash(password)
        verification_code = str(random.randint(100000, 999999))
        session['registration_info'] = {
            'full_name': full_name,
            'email': email,
            'password_hash': password_hash,
            'code': verification_code,
            'timestamp': datetime.now(timezone.utc).timestamp()
        }

        try:
            html_body = render_template(
                'email/verification_email.html', 
                full_name=full_name, 
                verification_code=verification_code
            )
            msg = Message(
                subject="Welcome! Verify Your Email for CampusFind",
                recipients=[email],
                html=html_body
            )
            mail.send(msg)
            flash(f'A verification code has been sent to {email}. Please check your inbox.', 'info')
            return redirect(url_for('verify_email'))
        except Exception as e:
            flash('Failed to send verification email. Please try again later.', 'danger')
            print(f"Email sending error: {e}")
            return redirect(url_for('register'))
    return render_template('register.html')

@app.route('/verify_email', methods=['GET', 'POST'])
def verify_email():
    if 'registration_info' not in session:
        flash('Please start the registration process first.', 'warning')
        return redirect(url_for('register'))
    
    reg_info = session['registration_info']
    
    try:
        reg_time = datetime.fromtimestamp(reg_info['timestamp'], tz=timezone.utc)
        if datetime.now(timezone.utc) - reg_time > timedelta(minutes=10):
            session.pop('registration_info', None)
            flash('Your verification code has expired. Please register again.', 'danger')
            return redirect(url_for('register'))
    except KeyError:
        session.pop('registration_info', None)
        flash('An error occurred. Please register again.', 'danger')
        return redirect(url_for('register'))

    if request.method == 'POST':
        user_code = request.form['code']
        
        if user_code == reg_info['code']:
            try:
                insert_user_query = text("INSERT INTO users (full_name, email, password_hash) VALUES (:full_name, :email, :password_hash)")
                result = db.session.execute(insert_user_query, {'full_name': reg_info['full_name'], 'email': reg_info['email'], 'password_hash': reg_info['password_hash']})
                user_id = result.lastrowid
                
                insert_role_query = text("INSERT INTO user_roles (user_id, role_id) VALUES (:user_id, 1)")
                db.session.execute(insert_role_query, {'user_id': user_id})
                
                db.session.commit()
                
                session.pop('registration_info', None)
                flash('Email verified successfully! You can now log in.', 'success')
                return redirect(url_for('login'))
            except Exception as e:
                db.session.rollback()
                flash('An error occurred while creating your account. Please try again.', 'danger')
                print(f"Database error during registration: {e}")
                return redirect(url_for('register'))
        else:
            flash('Invalid verification code. Please try again.', 'danger')
    
    return render_template('verify_email.html', email=reg_info.get('email', ''))

@app.route('/logout')
@login_required
def logout():
    session.clear()
    flash('You have been successfully logged out.', 'info')
    return redirect(url_for('index'))

@app.route('/forgot_password', methods=['GET', 'POST'])
def forgot_password():
    if request.method == 'POST':
        email = request.form['email']
        user = db.session.execute(text("SELECT id, email FROM users WHERE email = :email"), {'email': email}).fetchone()

        if user:
            session['reset_email'] = user.email
            return redirect(url_for('send_code'))
        else:
            flash('Email address not found. Please try again.', 'danger')
            return redirect(url_for('forgot_password'))
    return render_template('forgot_password.html')

@app.route('/send_code', methods=['GET', 'POST'])
def send_code():
    if 'reset_email' not in session:
        return redirect(url_for('forgot_password'))

    if request.method == 'POST':
        email = session['reset_email']
        reset_code = str(random.randint(100000, 999999))
        expiration_time = datetime.now(timezone.utc) + timedelta(minutes=10)

        update_query = text("UPDATE users SET reset_token = :code, reset_token_expiration = :exp WHERE email = :email")
        db.session.execute(update_query, {'code': reset_code, 'exp': expiration_time, 'email': email})
        db.session.commit()

        try:
            html_body = render_template(
                'email/reset_password_email.html', 
                reset_code=reset_code
            )
            msg = Message(
                subject="Your CampusFind Password Reset Code",
                recipients=[email],
                html=html_body
            )
            mail.send(msg)
            flash(f'A 6-digit code has been sent to {email}. Please check your inbox.', 'success')
        except Exception as e:
            flash('Failed to send email. Please check your configuration and try again.', 'danger')
            print(f"Email sending error: {e}")

        sender_email = app.config.get('MAIL_USERNAME')
        subject = 'Password Reset Code Sent'
        message_body = f"Password reset code sent to {email}."
        log_query = text("INSERT INTO email_logs (sender_email, recipient_email, subject, message) VALUES (:sender, :recipient, :subject, :msg)")
        db.session.execute(log_query, {'sender': sender_email, 'recipient': email, 'subject': subject, 'msg': message_body})
        db.session.commit()
        
        return redirect(url_for('verify_code'))
    return render_template('send_code.html', email=session['reset_email'])

@app.route('/verify_code', methods=['GET', 'POST'])
def verify_code():
    if 'reset_email' not in session:
        return redirect(url_for('forgot_password'))

    if request.method == 'POST':
        code = request.form['code']
        email = session['reset_email']
        
        query = text("SELECT id FROM users WHERE email = :email AND reset_token = :code AND reset_token_expiration > :now")
        user = db.session.execute(query, {'email': email, 'code': code, 'now': datetime.now(timezone.utc)}).fetchone()

        if user:
            session['code_verified'] = True
            return redirect(url_for('reset_password'))
        else:
            flash('Invalid or expired code. Please try again.', 'danger')
            return redirect(url_for('verify_code'))
    return render_template('verify_code.html', email=session['reset_email'])

@app.route('/reset_password', methods=['GET', 'POST'])
def reset_password():
    if not session.get('code_verified') or 'reset_email' not in session:
        flash('Please verify your code first.', 'warning')
        return redirect(url_for('forgot_password'))

    if request.method == 'POST':
        password = request.form['password']
        confirm_password = request.form['confirm_password']

        if password != confirm_password:
            flash('Passwords do not match. Please try again.', 'danger')
            return render_template('reset_password.html')

        password_hash = generate_password_hash(password)
        email = session['reset_email']
        
        query = text("UPDATE users SET password_hash = :p_hash, reset_token = NULL, reset_token_expiration = NULL WHERE email = :email")
        db.session.execute(query, {'p_hash': password_hash, 'email': email})
        db.session.commit()
        
        session.pop('reset_email', None)
        session.pop('code_verified', None)
        
        flash('Your password has been updated successfully. Please log in.', 'success')
        return redirect(url_for('login'))
        
    return render_template('reset_password.html')


# --- User-Specific Routes ---
@app.route('/dashboard')
@login_required
def dashboard():
    user_id = session['user_id']
    my_items_query = text("""
        SELECT i.*, c.name as category_name, 
               (SELECT COUNT(*) FROM feedback WHERE item_id = i.id AND reviewer_id = :user_id) as feedback_given
        FROM items i 
        JOIN categories c ON i.category_id = c.id 
        WHERE i.user_id = :user_id 
        ORDER BY i.reported_at DESC
    """)
    my_items = db.session.execute(my_items_query, {'user_id': user_id}).fetchall()

    my_claims_query = text("""
        SELECT c.*, i.title as item_title, i.status as item_status, i.id as item_id,
               (SELECT COUNT(*) FROM feedback WHERE item_id = i.id AND reviewer_id = :user_id) as feedback_given
        FROM claims c 
        JOIN items i ON c.item_id = i.id 
        WHERE c.claimant_user_id = :user_id AND c.status = 'approved'
        ORDER BY c.created_at DESC
    """)
    my_claims = db.session.execute(my_claims_query, {'user_id': user_id}).fetchall()
    
    my_alerts_query = text("""
        SELECT la.*, c.name as category_name, l.name as location_name
        FROM lost_item_alerts la
        JOIN categories c ON la.category_id = c.id
        LEFT JOIN locations l ON la.location_id = l.id
        WHERE la.user_id = :user_id AND la.is_active = TRUE
        ORDER BY la.alert_date DESC
    """)
    my_alerts = db.session.execute(my_alerts_query, {'user_id': user_id}).fetchall()

    return render_template('dashboard.html', my_items=my_items, my_claims=my_claims, my_alerts=my_alerts)

@app.route('/profile')
@login_required
def profile():
    return redirect(url_for('view_profile', user_id=session['user_id']))

@app.route('/user/<int:user_id>')
@login_required
def view_profile(user_id):
    user = db.session.execute(text("SELECT * FROM users WHERE id = :user_id"), {'user_id': user_id}).fetchone()
    if not user:
        flash("User not found.", "danger")
        return redirect(url_for('dashboard'))
    
    rating_data = db.session.execute(text("SELECT AVG(rating) as avg_rating, COUNT(rating) as rating_count FROM feedback WHERE reviewed_id = :user_id"), {'user_id': user_id}).fetchone()
    
    feedback_list_query = text("""
        SELECT f.*, u.full_name as reviewer_name 
        FROM feedback f 
        JOIN users u ON f.reviewer_id = u.id 
        WHERE f.reviewed_id = :user_id 
        ORDER BY f.created_at DESC LIMIT 5
    """)
    feedback_list = db.session.execute(feedback_list_query, {'user_id': user_id}).fetchall()
    
    reported_count = db.session.execute(text("SELECT COUNT(id) as count FROM items WHERE user_id = :user_id"), {'user_id': user_id}).scalar_one()
    
    approved_claims_count = db.session.execute(text("SELECT COUNT(id) as count FROM claims WHERE claimant_user_id = :user_id AND status = 'approved'"), {'user_id': user_id}).scalar_one()

    pending_claims_count = db.session.execute(text("SELECT COUNT(id) as count FROM claims WHERE claimant_user_id = :user_id AND status = 'pending'"), {'user_id': user_id}).scalar_one()
    
    stats = {
        'reported': reported_count,
        'approved_claims': approved_claims_count,
        'pending_claims': pending_claims_count
    }
    
    return render_template('profile.html', user=user, rating_data=rating_data, feedback_list=feedback_list, stats=stats)

@app.route('/profile/edit', methods=['GET', 'POST'])
@login_required
def edit_profile():
    user_id = session['user_id']
    if request.method == 'POST':
        full_name = request.form['full_name']
        contact_info = request.form['contact_info']
        address = request.form.get('address', '')
        secondary_email = request.form.get('secondary_email', '')
        
        update_query = text("UPDATE users SET full_name = :name, contact_info = :contact, address = :addr, secondary_email = :sec_email WHERE id = :user_id")
        db.session.execute(update_query, {'name': full_name, 'contact': contact_info, 'addr': address, 'sec_email': secondary_email, 'user_id': user_id})
        
        new_password = request.form.get('new_password')
        if new_password:
            password_hash = generate_password_hash(new_password)
            pass_query = text("UPDATE users SET password_hash = :p_hash WHERE id = :user_id")
            db.session.execute(pass_query, {'p_hash': password_hash, 'user_id': user_id})

        db.session.commit()
        session['full_name'] = full_name
        flash('Profile updated successfully.', 'success')
        return redirect(url_for('profile'))

    user = db.session.execute(text("SELECT * FROM users WHERE id = :user_id"), {'user_id': user_id}).fetchone()
    return render_template('edit_profile.html', user=user)

@app.route('/report', methods=['GET', 'POST'])
@login_required
def report_item():
    categories, locations = get_common_data()
    if request.method == 'POST':
        title = request.form['title']
        description = request.form['description']
        item_type = request.form['item_type']
        category_id = request.form['category_id']
        location_id = request.form['location_id']
        user_id = session['user_id']
        
        try:
            item_query = text("INSERT INTO items (user_id, category_id, location_id, title, description, item_type) VALUES (:user_id, :cat_id, :loc_id, :title, :desc, :type)")
            result = db.session.execute(item_query, {'user_id': user_id, 'cat_id': category_id, 'loc_id': location_id, 'title': title, 'desc': description, 'type': item_type})
            item_id = result.lastrowid

            images = request.files.getlist('images')
            for image in images:
                if image and allowed_file(image.filename):
                    filename = secure_filename(image.filename)
                    unique_filename = f"{item_id}_{datetime.now().strftime('%Y%m%d%H%M%S')}_{filename}"
                    save_path = os.path.join(app.config['UPLOAD_FOLDER'], unique_filename)
                    
                    image.save(save_path)

                    try:
                        img = Image.open(save_path)
                        img.thumbnail((800, 800)) 
                        img.save(save_path, optimize=True, quality=85)
                    except Exception as e:
                        print(f"Error optimizing image {filename}: {e}")

                    image_url = f"/{save_path.replace('//', '/')}" 
                    img_query = text("INSERT INTO item_images (item_id, image_url) VALUES (:item_id, :url)")
                    db.session.execute(img_query, {'item_id': item_id, 'url': image_url})

            tags = request.form.get('tags', '').split(',')
            for tag_name in tags:
                tag_name = tag_name.strip().lower()
                if tag_name:
                    tag_result = db.session.execute(text("SELECT id FROM tags WHERE name = :name"), {'name': tag_name}).fetchone()
                    if not tag_result:
                        tag_insert_res = db.session.execute(text("INSERT INTO tags (name) VALUES (:name)"), {'name': tag_name})
                        tag_id = tag_insert_res.lastrowid
                    else:
                        tag_id = tag_result.id
                    db.session.execute(text("INSERT INTO item_tags (item_id, tag_id) VALUES (:item_id, :tag_id)"), {'item_id': item_id, 'tag_id': tag_id})

            db.session.commit()

            if item_type == 'found':
                found_item = { 'id': item_id, 'title': title, 'category_id': category_id, 'user_id': user_id }
                check_for_matches_and_notify(found_item)

            flash('Successfully reported your item!', 'success')
            return redirect(url_for('dashboard'))
        except Exception as e:
            db.session.rollback()
            flash('An error occurred while reporting the item.', 'danger')
            print(f"Item reporting error: {e}")
            return redirect(url_for('report_item'))
            
    return render_template('report_item.html', categories=categories, locations=locations)

@app.route('/claim/item/<int:item_id>', methods=['GET', 'POST'])
@login_required
def claim_item(item_id):
    item_query = text("""
        SELECT i.id, i.title, i.user_id as reporter_id, u.full_name 
        FROM items i JOIN users u ON i.user_id = u.id 
        WHERE i.id = :item_id
    """)
    item = db.session.execute(item_query, {'item_id': item_id}).fetchone()

    if not item:
        flash("Item not found.", "danger")
        return redirect(url_for('index'))

    existing_claim = db.session.execute(text("SELECT id FROM claims WHERE item_id = :item_id AND claimant_user_id = :user_id"), {'item_id': item_id, 'user_id': session['user_id']}).fetchone()
    if existing_claim:
        flash('You have already submitted a claim for this item.', 'warning')
        return redirect(url_for('item_details', item_id=item_id))

    if request.method == 'POST':
        claim_description = request.form.get('claim_description')
        if not claim_description:
            flash('Please provide a description to prove ownership.', 'danger')
            return render_template('claim_form.html', item=item)

        insert_query = text("INSERT INTO claims (item_id, claimant_user_id, claim_description) VALUES (:item_id, :user_id, :desc)")
        db.session.execute(insert_query, {'item_id': item_id, 'user_id': session['user_id'], 'desc': claim_description})
        db.session.commit()
        
        message = f"'{session['full_name']}' has submitted a claim for your item: '{item.title}'."
        link = url_for('manage_claims')
        create_notification(user_id=item.reporter_id, message=message, link=link)
        
        flash('Your claim has been submitted. The admin will review it shortly.', 'success')
        return redirect(url_for('item_details', item_id=item_id))

    return render_template('claim_form.html', item=item)


@app.route('/feedback/add/<int:item_id>', methods=['GET', 'POST'])
@login_required
def leave_feedback(item_id):
    item = db.session.execute(text("SELECT * FROM items WHERE id = :item_id"), {'item_id': item_id}).fetchone()
    claim = db.session.execute(text("SELECT * FROM claims WHERE item_id = :item_id AND status = 'approved'"), {'item_id': item_id}).fetchone()

    if not item or not claim:
        flash("Invalid feedback request.", "danger")
        return redirect(url_for('dashboard'))

    reviewer_id = session['user_id']
    if reviewer_id == item.user_id:
        reviewed_id = claim.claimant_user_id
    elif reviewer_id == claim.claimant_user_id:
        reviewed_id = item.user_id
    else:
        flash("You are not part of this transaction.", "danger")
        return redirect(url_for('dashboard'))

    if db.session.execute(text("SELECT * FROM feedback WHERE item_id = :item_id AND reviewer_id = :reviewer_id"), {'item_id': item_id, 'reviewer_id': reviewer_id}).fetchone():
        flash("You have already left feedback for this transaction.", "warning")
        return redirect(url_for('dashboard'))

    if request.method == 'POST':
        rating = request.form['rating']
        comment = request.form.get('comment', '')
        query = text("INSERT INTO feedback (item_id, reviewer_id, reviewed_id, rating, comment) VALUES (:item_id, :rev_id, :reviewed_id, :rating, :comment)")
        db.session.execute(query, {'item_id': item_id, 'rev_id': reviewer_id, 'reviewed_id': reviewed_id, 'rating': rating, 'comment': comment})
        db.session.commit()
        flash("Thank you for your feedback!", "success")
        return redirect(url_for('dashboard'))

    reviewed_user = db.session.execute(text("SELECT full_name FROM users WHERE id = :id"), {'id': reviewed_id}).fetchone()
    
    return render_template('leave_feedback.html', item=item, reviewed_user=reviewed_user)

# --- Admin Routes ---
@app.route('/admin/dashboard')
@admin_required
def admin_dashboard():
    user_count = db.session.execute(text("SELECT COUNT(id) as count FROM users WHERE id NOT IN (SELECT user_id FROM user_roles WHERE role_id = 2)")).scalar_one()
    item_count = db.session.execute(text("SELECT COUNT(id) as count FROM items")).scalar_one()
    pending_claims_count = db.session.execute(text("SELECT COUNT(id) as count FROM claims WHERE status = 'pending'")).scalar_one()
    email_logs_count = db.session.execute(text("SELECT COUNT(id) as count FROM email_logs")).scalar_one()
    
    stats = {'users': user_count, 'item_count': item_count, 'pending_claims': pending_claims_count, 'email_logs': email_logs_count}
    
    recent_claims_query = text("""
        SELECT c.id, c.created_at as timestamp, 'claim' as type, i.title as item_title, u.full_name as user_name
        FROM claims c JOIN items i ON c.item_id = i.id JOIN users u ON c.claimant_user_id = u.id
        ORDER BY c.created_at DESC LIMIT 3
    """)
    recent_claims = db.session.execute(recent_claims_query).fetchall()

    recent_items_query = text("""
        SELECT i.id, i.reported_at as timestamp, 'item' as type, i.title as item_title, u.full_name as user_name
        FROM items i JOIN users u ON i.user_id = u.id
        ORDER BY i.reported_at DESC LIMIT 3
    """)
    recent_items = db.session.execute(recent_items_query).fetchall()

    recent_users_query = text("""
        SELECT id, created_at as timestamp, 'user' as type, full_name as user_name
        FROM users ORDER BY created_at DESC LIMIT 3
    """)
    recent_users = db.session.execute(recent_users_query).fetchall()
    
    recent_activity = sorted(list(recent_claims) + list(recent_items) + list(recent_users), key=lambda x: x.timestamp, reverse=True)

    return render_template('admin/admin_dashboard.html', stats=stats, recent_activity=recent_activity[:5])

@app.route('/admin/users')
@admin_required
def manage_users():
    query = text("SELECT u.*, r.role_name FROM users u LEFT JOIN user_roles ur ON u.id = ur.user_id LEFT JOIN roles r ON ur.role_id = r.id WHERE (ur.role_id IS NULL OR ur.role_id != 2) AND u.id != :user_id")
    users = db.session.execute(query, {'user_id': session['user_id']}).fetchall()
    return render_template('admin/manage_users.html', users=users)

@app.route('/admin/user/add', methods=['GET', 'POST'])
@admin_required
def admin_add_user():
    if request.method == 'POST':
        full_name = request.form['full_name']
        email = request.form['email']
        password = request.form['password']
        role_id = request.form.get('role_id', 1)

        existing_user = db.session.execute(text("SELECT id FROM users WHERE email = :email"), {'email': email}).fetchone()
        if existing_user:
            flash('An account with this email already exists.', 'danger')
            return redirect(url_for('admin_add_user'))

        password_hash = generate_password_hash(password)
        
        insert_user_query = text("INSERT INTO users (full_name, email, password_hash) VALUES (:name, :email, :p_hash)")
        result = db.session.execute(insert_user_query, {'name': full_name, 'email': email, 'p_hash': password_hash})
        user_id = result.lastrowid

        insert_role_query = text("INSERT INTO user_roles (user_id, role_id) VALUES (:user_id, :role_id)")
        db.session.execute(insert_role_query, {'user_id': user_id, 'role_id': role_id})

        db.session.commit()
        log_audit(f"Created new user: {full_name} (ID: {user_id})", 'user', user_id)
        flash(f'User {full_name} created successfully.', 'success')
        return redirect(url_for('manage_users'))

    roles = db.session.execute(text("SELECT * FROM roles")).fetchall()
    return render_template('admin/add_user.html', roles=roles)

@app.route('/admin/user/edit/<int:user_id>', methods=['GET', 'POST'])
@admin_required
def admin_edit_user(user_id):
    if request.method == 'POST':
        full_name = request.form['full_name']
        email = request.form['email']
        contact_info = request.form.get('contact_info', '')
        address = request.form.get('address', '')
        secondary_email = request.form.get('secondary_email', '')
        
        query = text("UPDATE users SET full_name=:name, email=:email, contact_info=:contact, address=:addr, secondary_email=:sec_email WHERE id=:user_id")
        db.session.execute(query, {'name': full_name, 'email': email, 'contact': contact_info, 'addr': address, 'sec_email': secondary_email, 'user_id': user_id})
        db.session.commit()
        
        log_audit(f"Edited user details for user ID: {user_id}", 'user', user_id)
        flash('User details updated successfully.', 'success')
        return redirect(url_for('manage_users'))

    user = db.session.execute(text("SELECT * FROM users WHERE id = :user_id"), {'user_id': user_id}).fetchone()
    return render_template('admin/edit_user.html', user=user)

@app.route('/admin/user/status/<int:user_id>', methods=['POST'])
@admin_required
def admin_update_user_status(user_id):
    action = request.form.get('action')
    if action not in ['activate', 'suspend']:
        flash("Invalid action.", "danger")
        return redirect(url_for('manage_users'))
    
    new_status = 'active' if action == 'activate' else 'suspended'
    
    db.session.execute(text("UPDATE users SET status = :status WHERE id = :user_id"), {'status': new_status, 'user_id': user_id})
    db.session.commit()
    
    log_audit(f"User ID {user_id} status changed to {new_status}", 'user', user_id)
    flash(f"User has been {new_status}.", "success")
    return redirect(url_for('manage_users'))

@app.route('/admin/items')
@admin_required
def manage_items():
    query = text("SELECT i.*, u.full_name, c.name as category_name FROM items i JOIN users u ON i.user_id = u.id JOIN categories c ON i.category_id = c.id ORDER BY i.reported_at DESC")
    items = db.session.execute(query).fetchall()
    return render_template('admin/manage_items.html', items=items)

@app.route('/admin/claims')
@admin_required
def manage_claims():
    query = text("""
        SELECT 
            c.id, c.status, c.created_at, c.claim_description,
            i.title as item_title, i.description as item_public_description,
            claimant.full_name as claimant_name, 
            reporter.full_name as reporter_name
        FROM claims c
        JOIN items i ON c.item_id = i.id
        JOIN users claimant ON c.claimant_user_id = claimant.id
        JOIN users reporter ON i.user_id = reporter.id
        ORDER BY c.created_at DESC
    """)
    claims = db.session.execute(query).fetchall()
    return render_template('admin/manage_claims.html', claims=claims)

@app.route('/admin/claim/update/<int:claim_id>/<string:action>', methods=['POST'])
@admin_required
def update_claim_status(claim_id, action):
    if action not in ['approved', 'rejected']:
        flash('Invalid action.', 'danger')
        return redirect(url_for('manage_claims'))
    
    claim_details_query = text("""
        SELECT c.claimant_user_id, i.title as item_title
        FROM claims c JOIN items i ON c.item_id = i.id
        WHERE c.id = :claim_id
    """)
    claim_details = db.session.execute(claim_details_query, {'claim_id': claim_id}).fetchone()

    if not claim_details:
        flash("Claim not found.", "danger")
        return redirect(url_for('manage_claims'))

    db.session.execute(text("UPDATE claims SET status = :action WHERE id = :claim_id"), {'action': action, 'claim_id': claim_id})
    
    if action == 'approved':
        item_id_result = db.session.execute(text("SELECT item_id FROM claims WHERE id = :claim_id"), {'claim_id': claim_id}).fetchone()
        if item_id_result:
            item_id = item_id_result.item_id
            db.session.execute(text("UPDATE items SET status = 'retrieved' WHERE id = :item_id"), {'item_id': item_id})
    
    db.session.commit()
    
    message = f"Your claim for the item '{claim_details.item_title}' has been {action}."
    link = url_for('inbox')
    create_notification(user_id=claim_details.claimant_user_id, message=message, link=link)

    log_audit(f"Updated claim ID {claim_id} to '{action}'", 'claim', claim_id)
    flash(f'Claim has been {action}.', 'success')
    return redirect(url_for('manage_claims'))

@app.route('/admin/audit_logs')
@admin_required
def admin_audit_logs():
    query = text("""
        SELECT a.*, u.full_name as admin_name 
        FROM audit_logs a
        JOIN users u ON a.admin_id = u.id
        ORDER BY a.action_at DESC
    """)
    logs = db.session.execute(query).fetchall()
    return render_template('admin/audit_log.html', logs=logs)

@app.route('/admin/item/add', methods=['GET', 'POST'])
@admin_required
def add_item():
    categories, locations = get_common_data()
    if request.method == 'POST':
        user_id = session['user_id']
        title = request.form['title']
        description = request.form['description']
        item_type = request.form['item_type']
        category_id = request.form['category_id']
        location_id = request.form['location_id']
        
        insert_query = text("INSERT INTO items (user_id, category_id, location_id, title, description, item_type) VALUES (:user_id, :cat_id, :loc_id, :title, :desc, :type)")
        result = db.session.execute(insert_query, {'user_id': user_id, 'cat_id': category_id, 'loc_id': location_id, 'title': title, 'desc': description, 'type': item_type})
        item_id = result.lastrowid
        db.session.commit()
        
        log_audit(f"Added new item ID: {item_id}", 'item', item_id)
        flash('New item added successfully.', 'success')
        return redirect(url_for('manage_items'))

    return render_template('admin/edit_item.html', categories=categories, locations=locations, form_action=url_for('add_item'), page_title="Add New Item")

@app.route('/admin/item/edit/<int:item_id>', methods=['GET', 'POST'])
@admin_required
def edit_item(item_id):
    categories, locations = get_common_data()
    if request.method == 'POST':
        title = request.form['title']
        description = request.form['description']
        category_id = request.form['category_id']
        location_id = request.form['location_id']
        status = request.form['status']
        query = text("UPDATE items SET title=:title, description=:desc, category_id=:cat_id, location_id=:loc_id, status=:status WHERE id=:item_id")
        db.session.execute(query, {'title': title, 'desc': description, 'cat_id': category_id, 'loc_id': location_id, 'status': status, 'item_id': item_id})
        db.session.commit()
        
        log_audit(f"Edited item ID: {item_id}", 'item', item_id)
        flash('Item updated successfully.', 'success')
        return redirect(url_for('manage_items'))
    
    item = db.session.execute(text("SELECT * FROM items WHERE id = :item_id"), {'item_id': item_id}).fetchone()
    return render_template('admin/edit_item.html', item=item, categories=categories, locations=locations, form_action=url_for('edit_item', item_id=item_id), page_title="Edit Item")

@app.route('/admin/item/delete/<int:item_id>', methods=['POST'])
@admin_required
def delete_item(item_id):
    db.session.execute(text("DELETE FROM items WHERE id = :item_id"), {'item_id': item_id})
    db.session.commit()
    log_audit(f"Deleted item ID: {item_id}", 'item', item_id)
    flash('Item deleted successfully.', 'success')
    return redirect(url_for('manage_items'))

@app.route('/send_email/<int:item_id>', methods=['POST'])
@login_required
def send_email(item_id):
    recipient_email = request.form['recipient_email']
    subject = request.form['subject']
    message_body = request.form['message']
    sender_email = session.get('email')
    sender_name = session.get('full_name')

    try:
        msg = Message(
            subject=subject,
            recipients=[recipient_email],
            body=f"Message from {sender_name} ({sender_email}) regarding your found item:\n\n---\n\n{message_body}",
            reply_to=sender_email
        )
        mail.send(msg)
        flash("Your message has been sent successfully!", "success")
    except Exception as e:
        flash("There was an error sending your message. Please try again later.", "danger")
        print(f"Email sending error: {e}")

    query = text("""
        INSERT INTO email_logs (sender_email, recipient_email, subject, message, item_id)
        VALUES (:sender, :recipient, :subject, :msg, :item_id)
    """)
    db.session.execute(query, {'sender': sender_email, 'recipient': recipient_email, 'subject': subject, 'msg': message_body, 'item_id': item_id})
    db.session.commit()

    return redirect(url_for('item_details', item_id=item_id))

@app.route('/admin/email_logs')
@admin_required
def admin_email_logs():
    query = text("""
        SELECT el.*, u.full_name as sender_name, i.title as item_title
        FROM email_logs el
        JOIN users u ON el.sender_email = u.email
        LEFT JOIN items i ON el.item_id = i.id
        ORDER BY el.sent_at DESC
    """)
    logs = db.session.execute(query).fetchall()
    return render_template('admin/email_logs.html', logs=logs)

@app.route('/admin/locations')
@admin_required
def manage_locations():
    locations = db.session.execute(text("SELECT * FROM locations ORDER BY name")).fetchall()
    return render_template('admin/manage_locations.html', locations=locations)

@app.route('/admin/location/add', methods=['POST'])
@admin_required
def add_location():
    if request.method == 'POST':
        name = request.form['name']
        db.session.execute(text("INSERT INTO locations (name) VALUES (:name)"), {'name': name})
        db.session.commit()
        log_audit(f"Added new location: {name}", 'location')
        flash('New location added successfully.', 'success')
    return redirect(url_for('manage_locations'))

@app.route('/admin/location/edit/<int:loc_id>', methods=['POST'])
@admin_required
def edit_location(loc_id):
    if request.method == 'POST':
        name = request.form['name']
        db.session.execute(text("UPDATE locations SET name = :name WHERE id = :loc_id"), {'name': name, 'loc_id': loc_id})
        db.session.commit()
        log_audit(f"Edited location ID {loc_id} to: {name}", 'location', loc_id)
        flash('Location updated successfully.', 'success')
    return redirect(url_for('manage_locations'))

@app.route('/admin/location/delete/<int:loc_id>', methods=['POST'])
@admin_required
def delete_location(loc_id):
    db.session.execute(text("DELETE FROM locations WHERE id = :loc_id"), {'loc_id': loc_id})
    db.session.commit()
    log_audit(f"Deleted location ID: {loc_id}", 'location', loc_id)
    flash('Location deleted successfully.', 'danger')
    return redirect(url_for('manage_locations'))

@app.route('/admin/categories')
@admin_required
def manage_categories():
    categories = db.session.execute(text("SELECT * FROM categories ORDER BY name")).fetchall()
    return render_template('admin/manage_categories.html', categories=categories)

@app.route('/admin/category/add', methods=['POST'])
@admin_required
def add_category():
    if request.method == 'POST':
        name = request.form['name']
        db.session.execute(text("INSERT INTO categories (name) VALUES (:name)"), {'name': name})
        db.session.commit()
        log_audit(f"Added new category: {name}", 'category')
        flash('New category added successfully.', 'success')
    return redirect(url_for('manage_categories'))

@app.route('/admin/category/edit/<int:cat_id>', methods=['POST'])
@admin_required
def edit_category(cat_id):
    if request.method == 'POST':
        name = request.form['name']
        db.session.execute(text("UPDATE categories SET name = :name WHERE id = :cat_id"), {'name': name, 'cat_id': cat_id})
        db.session.commit()
        log_audit(f"Edited category ID {cat_id} to: {name}", 'category', cat_id)
        flash('Category updated successfully.', 'success')
    return redirect(url_for('manage_categories'))

@app.route('/admin/category/delete/<int:cat_id>', methods=['POST'])
@admin_required
def delete_category(cat_id):
    db.session.execute(text("DELETE FROM categories WHERE id = :cat_id"), {'cat_id': cat_id})
    db.session.commit()
    log_audit(f"Deleted category ID: {cat_id}", 'category', cat_id)
    flash('Category deleted successfully.', 'danger')
    return redirect(url_for('manage_categories'))

# =================================================================
#   MESSAGING SYSTEM ROUTES
# =================================================================

@app.route('/messages')
@login_required
def inbox():
    user_id = session['user_id']
    query = text("""
        SELECT 
            c.id as claim_id, 
            i.title as item_title,
            reporter.id as reporter_id,
            reporter.full_name as reporter_name,
            claimant.id as claimant_id,
            claimant.full_name as claimant_name,
            (SELECT COUNT(*) FROM messages WHERE claim_id = c.id AND recipient_id = :user_id AND is_read = 0) as unread_count
        FROM claims c
        JOIN items i ON c.item_id = i.id
        JOIN users reporter ON i.user_id = reporter.id
        JOIN users claimant ON c.claimant_user_id = claimant.id
        WHERE c.status = 'approved' AND (i.user_id = :user_id OR c.claimant_user_id = :user_id)
        ORDER BY c.created_at DESC
    """)
    conversations = db.session.execute(query, {'user_id': user_id}).fetchall()
    return render_template('inbox.html', conversations=conversations)

@app.route('/messages/claim/<int:claim_id>', methods=['GET', 'POST'])
@login_required
def conversation(claim_id):
    user_id = session['user_id']
    claim_query = text("""
        SELECT 
            c.id as claim_id, c.claimant_user_id,
            i.id as item_id, i.title as item_title, i.user_id as reporter_id,
            reporter.full_name as reporter_name,
            claimant.full_name as claimant_name
        FROM claims c
        JOIN items i ON c.item_id = i.id
        JOIN users reporter ON i.user_id = reporter.id
        JOIN users claimant ON c.claimant_user_id = claimant.id
        WHERE c.id = :claim_id AND c.status = 'approved'
    """)
    claim_info = db.session.execute(claim_query, {'claim_id': claim_id}).fetchone()

    if not claim_info:
        flash("Conversation not found or claim is not approved.", "danger")
        return redirect(url_for('inbox'))

    if user_id not in [claim_info.reporter_id, claim_info.claimant_user_id]:
        flash("You do not have permission to view this conversation.", "danger")
        return redirect(url_for('inbox'))

    if request.method == 'POST':
        body = request.form.get('body')
        if body:
            recipient_id = claim_info.reporter_id if user_id == claim_info.claimant_user_id else claim_info.claimant_user_id
            
            message_query = text("""
                INSERT INTO messages (claim_id, sender_id, recipient_id, body)
                VALUES (:claim_id, :sender_id, :recipient_id, :body)
            """)
            db.session.execute(message_query, {
                'claim_id': claim_id,
                'sender_id': user_id,
                'recipient_id': recipient_id,
                'body': body
            })
            db.session.commit()

            message = f"You have a new message from {session['full_name']} regarding '{claim_info.item_title}'."
            link = url_for('conversation', claim_id=claim_id)
            create_notification(user_id=recipient_id, message=message, link=link)

            return redirect(url_for('conversation', claim_id=claim_id))

    messages_query = text("""
        SELECT m.*, u.full_name as sender_name
        FROM messages m
        JOIN users u ON m.sender_id = u.id
        WHERE m.claim_id = :claim_id
        ORDER BY m.sent_at ASC
    """)
    messages = db.session.execute(messages_query, {'claim_id': claim_id}).fetchall()

    update_read_query = text("UPDATE messages SET is_read = 1 WHERE claim_id = :claim_id AND recipient_id = :user_id")
    db.session.execute(update_read_query, {'claim_id': claim_id, 'user_id': user_id})
    db.session.commit()

    other_user_name = claim_info.reporter_name if user_id == claim_info.claimant_user_id else claim_info.claimant_name

    return render_template('conversation.html', messages=messages, claim_info=claim_info, other_user_name=other_user_name)

# =================================================================
#   NOTIFICATION & LOST ITEM ALERT ROUTES
# =================================================================

@app.route('/notifications')
@login_required
def notifications():
    user_id = session['user_id']
    query = text("SELECT * FROM notifications WHERE user_id = :user_id ORDER BY created_at DESC")
    all_notifications = db.session.execute(query, {'user_id': user_id}).fetchall()
    return render_template('notifications.html', all_notifications=all_notifications)

@app.route('/notifications/mark-read/<int:notification_id>')
@login_required
def mark_notification_read(notification_id):
    user_id = session['user_id']
    
    link_query = text("SELECT link FROM notifications WHERE id = :id AND user_id = :user_id")
    notification = db.session.execute(link_query, {'id': notification_id, 'user_id': user_id}).fetchone()
    
    if not notification:
        flash("Notification not found.", "danger")
        return redirect(url_for('index'))

    query = text("UPDATE notifications SET is_read = TRUE WHERE id = :id AND user_id = :user_id")
    db.session.execute(query, {'id': notification_id, 'user_id': user_id})
    db.session.commit()
    
    if notification.link:
        return redirect(notification.link)
    return redirect(url_for('notifications'))

@app.route('/lost-alert/new', methods=['GET', 'POST'])
@login_required
def new_lost_alert():
    categories, locations = get_common_data()
    if request.method == 'POST':
        title = request.form['title']
        description = request.form['description']
        category_id = request.form['category_id']
        location_id = request.form.get('location_id')

        query = text("""
            INSERT INTO lost_item_alerts (user_id, category_id, location_id, title, description)
            VALUES (:user_id, :cat_id, :loc_id, :title, :desc)
        """)
        db.session.execute(query, {
            'user_id': session['user_id'],
            'cat_id': category_id,
            'loc_id': location_id if location_id else None,
            'title': title,
            'desc': description
        })
        db.session.commit()
        flash("Your lost item alert has been created.", "success")
        return redirect(url_for('manage_lost_alerts'))

    return render_template('new_lost_alert.html', categories=categories, locations=locations)

@app.route('/lost-alert/manage')
@login_required
def manage_lost_alerts():
    user_id = session['user_id']
    query = text("""
        SELECT la.*, c.name as category_name, l.name as location_name
        FROM lost_item_alerts la
        JOIN categories c ON la.category_id = c.id
        LEFT JOIN locations l ON la.location_id = l.id
        WHERE la.user_id = :user_id
        ORDER BY la.alert_date DESC
    """)
    alerts = db.session.execute(query, {'user_id': user_id}).fetchall()
    return render_template('manage_lost_alerts.html', alerts=alerts)

@app.route('/lost-alert/delete/<int:alert_id>', methods=['POST'])
@login_required
def delete_lost_alert(alert_id):
    user_id = session['user_id']
    db.session.execute(text("DELETE FROM lost_item_alerts WHERE id = :alert_id AND user_id = :user_id"), 
                       {'alert_id': alert_id, 'user_id': user_id})
    db.session.commit()
    flash("Alert deleted successfully.", "success")
    return redirect(url_for('manage_lost_alerts'))

# --- NEW: Announcement Routes for Admin ---
@app.route('/admin/announcements', methods=['GET'])
@admin_required
def manage_announcements():
    query = text("SELECT a.*, u.full_name as admin_name FROM announcements a JOIN users u ON a.admin_id = u.id ORDER BY a.created_at DESC")
    announcements = db.session.execute(query).fetchall()
    return render_template('admin/manage_announcements.html', announcements=announcements)

@app.route('/admin/announcement/add', methods=['POST'])
@admin_required
def admin_add_announcement():
    content = request.form.get('content')
    if content:
        db.session.execute(text("UPDATE announcements SET is_active = FALSE"))
        query = text("INSERT INTO announcements (admin_id, content, is_active) VALUES (:admin_id, :content, TRUE)")
        db.session.execute(query, {'admin_id': session['user_id'], 'content': content})
        db.session.commit()
        log_audit(f"Posted new announcement: {content[:30]}...", 'announcement')
        flash("New announcement has been posted.", "success")
    return redirect(url_for('manage_announcements'))

@app.route('/admin/announcement/edit/<int:ann_id>', methods=['GET', 'POST'])
@admin_required
def admin_edit_announcement(ann_id):
    announcement = db.session.execute(text("SELECT * FROM announcements WHERE id = :id"), {'id': ann_id}).fetchone()
    if not announcement:
        flash("Announcement not found.", "danger")
        return redirect(url_for('manage_announcements'))

    if request.method == 'POST':
        content = request.form.get('content')
        if content:
            db.session.execute(text("UPDATE announcements SET content = :content WHERE id = :id"), {'content': content, 'id': ann_id})
            db.session.commit()
            log_audit(f"Edited announcement ID: {ann_id}", 'announcement', ann_id)
            flash("Announcement updated successfully.", "success")
            return redirect(url_for('manage_announcements'))

    return render_template('admin/edit_announcement.html', announcement=announcement)

@app.route('/admin/announcement/toggle/<int:ann_id>', methods=['POST'])
@admin_required
def admin_toggle_announcement(ann_id):
    action = request.form.get('action')
    if action == 'activate':
        db.session.execute(text("UPDATE announcements SET is_active = FALSE"))
        db.session.execute(text("UPDATE announcements SET is_active = TRUE WHERE id = :id"), {'id': ann_id})
        flash("Announcement has been set to active.", "success")
        log_audit(f"Activated announcement ID: {ann_id}", 'announcement', ann_id)
    elif action == 'deactivate':
        db.session.execute(text("UPDATE announcements SET is_active = FALSE WHERE id = :id"), {'id': ann_id})
        flash("Announcement has been deactivated.", "success")
        log_audit(f"Deactivated announcement ID: {ann_id}", 'announcement', ann_id)
    
    db.session.commit()
    return redirect(url_for('manage_announcements'))

@app.route('/admin/announcement/delete/<int:ann_id>', methods=['POST'])
@admin_required
def admin_delete_announcement(ann_id):
    announcement = db.session.execute(text("SELECT * FROM announcements WHERE id = :id"), {'id': ann_id}).fetchone()
    if announcement:
        db.session.execute(text("DELETE FROM announcements WHERE id = :id"), {'id': ann_id})
        db.session.commit()
        log_audit(f"Deleted announcement ID: {ann_id}", 'announcement', ann_id)
        flash("Announcement has been permanently deleted.", "success")
    else:
        flash("Announcement not found.", "danger")
    return redirect(url_for('manage_announcements'))


if __name__ == '__main__':
    app.run(debug=True)
