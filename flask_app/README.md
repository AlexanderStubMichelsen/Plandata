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

to compare latest vs. new :

update 				        press Run Update Script

OBS.        Wait for it to finish!!!

hash >> old   			    press Run Hash Script

hash >> new	

compare				        press Run Compare Script

view compared results 		press View Combined Output

