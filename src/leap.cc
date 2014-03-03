// Copyright (C) 2014 Chi-kwan Chan
// Copyright (C) 2014 Steward Observatory
//
// This file is part of GRay.
//
// GRay is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// GRay is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
// License for more details.
//
// You should have received a copy of the GNU General Public License
// along with GRay.  If not, see <http://www.gnu.org/licenses/>.

#include "gray.h"

#ifndef DISABLE_LEAP
#include <Leap.h>

class GRayLeapListener : public Leap::Listener {
  public:
    virtual void onConnect(const Leap::Controller&);
    virtual void onFrame  (const Leap::Controller&);
};

void GRayLeapListener::onConnect(const Leap::Controller& controller)
{
  controller.enableGesture(Leap::Gesture::TYPE_KEY_TAP);
  controller.enableGesture(Leap::Gesture::TYPE_CIRCLE);
}

void GRayLeapListener::onFrame(const Leap::Controller& controller)
{
  // Get the most recent frame and report some basic information
  const Leap::Frame frame = controller.frame();

  const Leap::GestureList gestures = frame.gestures();
  const Leap::HandList    hands    = frame.hands();

  if (!gestures.isEmpty()) {
    Leap::Gesture gesture = gestures[gestures.count()-1];

    switch (gesture.type()) {
    case Leap::Gesture::TYPE_KEY_TAP:
      print("Key tap gesture\n");
      {
        const double temp = global::dt_saved;
        global::dt_saved = global::dt_dump;
        global::dt_dump = temp;
      }
      break;
    case Leap::Gesture::TYPE_CIRCLE:
      print("Circle gesture\n");
      {
	Leap::CircleGesture circle = gesture;

        if (circle.pointable().direction().angleTo(circle.normal())
            <= Leap::PI/4) {
          if (global::dt_dump != 0.0)
            global::dt_dump  = -fabs(global::dt_dump);
          else {
            global::dt_dump  = -fabs(global::dt_saved);
            global::dt_saved = 0.0;
	  }
        } else {
          if (global::dt_dump != 0.0)
            global::dt_dump  = +fabs(global::dt_dump);
          else {
            global::dt_dump  = +fabs(global::dt_saved);
            global::dt_saved = 0.0;
	  }
        }
      }
      break;
    default:
      print("Unknown gesture type\n");
      break;
    }
  } else if (!hands.isEmpty()) {
    if (hands.count() == 1) {
      const Leap::FingerList fingers = hands[0].fingers();
      if (fingers.count() == 1) {
        print("Rotating\n");
      }
    } else (hands.count() == 2) {
      const Leap::FingerList lfingers = hands[0].fingers();
      const Leap::FingerList rfingers = hands[1].fingers();
      if (lfingers.count() == 1 && rfingers.count() == 1) {
        print("Zooming\n");
      }
    }
  }
}

static Leap::Controller *controller = NULL;
static GRayLeapListener *listener   = NULL;

static void setup()
{
  print("Leaping motion...");
  controller = new Leap::Controller;
  listener   = new GRayLeapListener;
  controller->addListener(*listener);
  print(" DONE\n");
}

static void cleanup()
{
  print("Cleanup...");
  controller->removeListener(*listener);
  print(" DONE\n");
}

void sense()
{
  if(!controller && !atexit(cleanup)) setup();
}
#endif
