#!/bin/bash
set -e

echo "🚗 Setting up CinciMiata Preview project with members, events, RSVPs & confirmations..."

# Create directories
mkdir -p app/templates
mkdir -p app/static/css

# ---------------------------
# Dockerfile
# ---------------------------
cat > Dockerfile <<'EOF'
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN chmod +x docker-entrypoint.sh

EXPOSE 80
ENTRYPOINT ["./docker-entrypoint.sh"]
EOF

# ---------------------------
# requirements.txt
# ---------------------------
cat > requirements.txt <<'EOF'
Flask==3.0.0
Flask-SQLAlchemy==3.1.1
Flask-Login==0.6.3
Flask-Mail==0.9.1
python-dotenv==1.0.1
gunicorn==21.2.0
EOF

# ---------------------------
# docker-entrypoint.sh
# ---------------------------
cat > docker-entrypoint.sh <<'EOF'
#!/bin/bash
flask db upgrade || true
exec gunicorn -b 0.0.0.0:80 app.main:app
EOF
chmod +x docker-entrypoint.sh

# ---------------------------
# app/__init__.py
# ---------------------------
cat > app/__init__.py <<'EOF'
# Makes app a package
EOF

# ---------------------------
# app/main.py
# ---------------------------
cat > app/main.py <<'EOF'
from flask import Flask, render_template, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
import os
from datetime import datetime

app = Flask(__name__)
app.config['SECRET_KEY'] = os.environ.get("SECRET_KEY", "devsecret")
app.config['SQLALCHEMY_DATABASE_URI'] = "sqlite:///site.db"

db = SQLAlchemy(app)

class Member(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)

class Event(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    date = db.Column(db.String(50), nullable=False)
    location = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text, nullable=True)

class RSVP(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    member_id = db.Column(db.Integer, db.ForeignKey('member.id'), nullable=False)
    event_id = db.Column(db.Integer, db.ForeignKey('event.id'), nullable=False)
    member = db.relationship("Member", backref="rsvps")
    event = db.relationship("Event", backref="rsvps")

@app.route("/")
def home():
    events = Event.query.order_by(Event.date).limit(3).all()
    return render_template("index.html", events=events)

@app.route("/members")
def members():
    all_members = Member.query.all()
    return render_template("members.html", members=all_members)

@app.route("/events")
def events():
    all_events = Event.query.order_by(Event.date).all()
    return render_template("events.html", events=all_events)

@app.route("/events/<int:event_id>")
def event_detail(event_id):
    event = Event.query.get_or_404(event_id)
    attendees = [rsvp.member for rsvp in event.rsvps]
    all_members = Member.query.all()
    return render_template("event_detail.html", event=event, attendees=attendees, members=all_members)

@app.route("/rsvp/<int:event_id>/<int:member_id>")
def rsvp(event_id, member_id):
    existing = RSVP.query.filter_by(event_id=event_id, member_id=member_id).first()
    if not existing:
        new_rsvp = RSVP(event_id=event_id, member_id=member_id)
        db.session.add(new_rsvp)
        db.session.commit()
    return redirect(url_for("event_detail", event_id=event_id))

@app.route("/cancel_rsvp/<int:event_id>/<int:member_id>")
def cancel_rsvp(event_id, member_id):
    existing = RSVP.query.filter_by(event_id=event_id, member_id=member_id).first()
    if existing:
        db.session.delete(existing)
        db.session.commit()
    return redirect(url_for("event_detail", event_id=event_id))

def seed_data():
    if Member.query.count() == 0:
        sample_members = [
            Member(name="Ken Bogart", email="ken@cincimiata.com"),
            Member(name="Jane Doe", email="jane@example.com"),
            Member(name="John Smith", email="john@example.com")
        ]
        db.session.add_all(sample_members)

    if Event.query.count() == 0:
        sample_events = [
            Event(title="Fall Cruise", date="2025-10-01", location="Scenic Byway", description="Join us for a fall foliage cruise."),
            Event(title="Cars & Coffee", date="2025-09-15", location="Downtown Cafe", description="Monthly meet-up for Miata enthusiasts.")
        ]
        db.session.add_all(sample_events)

    db.session.commit()
    print("✅ Sample data added.")

if __name__ == "__main__":
    with app.app_context():
        db.create_all()
        seed_data()
    app.run(host="0.0.0.0", port=80)
EOF

# ---------------------------
# Templates
# ---------------------------

# index.html
cat > app/templates/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
  <title>CinciMiata Preview</title>
</head>
<body>
  <h1>Welcome to CinciMiata</h1>
  <p>This is a preview site running in Docker.</p>

  <h2>Upcoming Events</h2>
  <ul>
    {% for e in events %}
      <li>
        <a href="{{ url_for('event_detail', event_id=e.id) }}">{{ e.title }}</a> 
        ({{ e.date }} - {{ e.location }})
      </li>
    {% endfor %}
  </ul>

  <p><a href="{{ url_for('events') }}">View All Events</a></p>
  <p><a href="{{ url_for('members') }}">View Members</a></p>
</body>
</html>
EOF

# members.html
cat > app/templates/members.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
  <title>Members</title>
</head>
<body>
  <h1>Members</h1>
  <ul>
    {% for m in members %}
      <li>{{ m.name }} ({{ m.email }})</li>
    {% endfor %}
  </ul>
  <a href="{{ url_for('home') }}">Back</a>
</body>
</html>
EOF

# events.html
cat > app/templates/events.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
  <title>Events</title>
</head>
<body>
  <h1>Events</h1>
  <ul>
    {% for e in events %}
      <li>
        <a href="{{ url_for('event_detail', event_id=e.id) }}">{{ e.title }}</a> 
        ({{ e.date }} - {{ e.location }})
      </li>
    {% endfor %}
  </ul>
  <a href="{{ url_for('home') }}">Back</a>
</body>
</html>
EOF

# event_detail.html
cat > app/templates/event_detail.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
  <title>{{ event.title }}</title>
</head>
<body>
  <h1>{{ event.title }}</h1>
  <p><strong>Date:</strong> {{ event.date }}</p>
  <p><strong>Location:</strong> {{ event.location }}</p>
  <p><strong>Description:</strong> {{ event.description }}</p>

  <h2>Attendees</h2>
  <ul>
    {% for member in attendees %}
      <li>
        {{ member.name }} ({{ member.email }})
        <a href="{{ url_for('cancel_rsvp', event_id=event.id, member_id=member.id) }}"
           onclick="return confirm('Are you sure you want to cancel this RSVP for {{ member.name }}?');">
           [Cancel]
        </a>
      </li>
    {% else %}
      <li>No RSVPs yet</li>
    {% endfor %}
  </ul>

  <h2>RSVP</h2>
  <ul>
    {% for m in members %}
      <li>
        <a href="{{ url_for('rsvp', event_id=event.id, member_id=m.id) }}"
           onclick="return confirm('Are you sure you want to RSVP as {{ m.name }}?');">
           RSVP as {{ m.name }}
        </a>
      </li>
    {% endfor %}
  </ul>

  <a href="{{ url_for('events') }}">Back to Events</a>
</body>
</html>
EOF

echo "✅ Complete CinciMiata setup done."
echo "👉 Build and run with: docker build -t cincimiata . && docker run -p 80:80 cincimiata"
