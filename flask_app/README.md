GO TO FLASK APP ROOT FOLDER

source venv/bin/activate

GO TO APP FOLDER

python app.py

GO TO YOUR BROWSER

http://127.0.0.1:5000/

DEACTIVATE VENV

deactivate

to kill press ctrl + c

OR 

pkill -f app.py

CHANGE USER RIGHTS TO CRAWLER FOR WORKING DIRECTORY

sudo chown -R crawler:crawler $(pwd)
