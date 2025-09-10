from flask import Flask, render_template, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
from app.config import Config  # <-- new line

from datetime import datetime

import os

app = Flask(__name__)
app.config.from_object(Config)  # <-- use Config
db = SQLAlchemy(app)

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
