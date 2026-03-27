# Project
We want to implement a iOS application that helps with Wim Hoff Method breathing. The application, call it Wim Hoff Auto Tracker, WHAT for short, should allow practioners to start a WHM breathing session. In each session the user can:

- Specify the number of cycles. Offer 1, 3 and 4 as defaults.
- Specifiy the number of breaths in   each breathing cycle. Offer defaults: 25, 35, 45, 55
- Specify the cadence of the breaths in breaths per second. Offer defaults: 2, 1.5, 1, 0.5
-
WHAT should remember the last user choice and default to that.

A WHM session cosistns of a number of cycles, each cycle goes through the following phases:
- Power Breathing: During this phase WHAT should draw an animation of a circle which fills on inhale and fills out on exale, as well as a counter of the number of breaths already taken. The circle animation is intended to guide the user to the correct breath rythm and should respect the cadence specified for the session
- Retention: When transitioning to this phase WHAT should display an indicative message, start a timer and draw a button that allows the user to signal he concluded the retention. When the user chooses to conclude the retention phase the retention time should be logged. 
- Recovery: WHAT should display an indicative message and start a 15 second timer. When the timer concludes WHAT should go back to the Power Breathing phase and loop until the desired number of cycles is performed.

Throughout the entire session WHAT should capture the user hearth rate, displaying the current value. At the end of the session a retrospective graph with the HR value on a minute by minute basis, superimposed with a cycle and phase timeline.

Session data, including number of cycles, number of breaths, cadence, retention times and HR data should be stored in a database and viewable for any date.



