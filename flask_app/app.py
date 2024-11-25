from flask import Flask, render_template, request
import subprocess
import os

app = Flask(__name__)

# Paths to your scripts
SCRIPT_COMPARE_PATH = os.path.join(os.path.dirname(__file__), '../master_scripts/comparing/compare_all_tables_hash.sh')
SCRIPT_HASH_PATH = os.path.join(os.path.dirname(__file__), '../master_scripts/hashing/hash_all_tables.sh')
SCRIPT_UPDATE_PATH = os.path.join(os.path.dirname(__file__), '../master_scripts/update/update_all_relevant_features.sh')

# Path to the timestamp file
UPDATE_TIMESTAMP_PATH = os.path.join(
    os.path.dirname(__file__), 
    '../master_scripts/update/update_logs_and_error_etc/last_download.txt'
)

@app.route('/')
def index():
    """Render the admin console with the latest timestamp."""
    # Default timestamp
    update_timestamp = "No timestamp found"
    
    # Try reading the timestamp from the file
    if os.path.exists(UPDATE_TIMESTAMP_PATH):
        with open(UPDATE_TIMESTAMP_PATH, 'r') as file:
            update_timestamp = file.read().strip()
    
    return render_template('index.html', update_timestamp=update_timestamp)

def execute_script(script_path, name):
    """Helper function to execute a script and return the output."""
    try:
        if not os.path.isfile(script_path):
            return f"<h2>Error:</h2><pre>Script not found at {script_path}</pre>"

        # Run the script and capture its output
        result = subprocess.run(['bash', script_path], capture_output=True, text=True)
        if result.returncode == 0:
            return f"<h2>{name} Script Output:</h2><pre>{result.stdout}</pre>"
        else:
            return f"<h2>{name} Script Error:</h2><pre>{result.stderr}</pre>"
    except Exception as e:
        return f"<h2>An error occurred with {name}:</h2><pre>{str(e)}</pre>"

@app.route('/run-script-update', methods=['POST'])
def run_script_update():
    """Execute the update script."""
    return execute_script(SCRIPT_UPDATE_PATH, 'Update')

@app.route('/run-script-hash', methods=['POST'])
def run_script_hash():
    """Execute the hash script."""
    return execute_script(SCRIPT_HASH_PATH, 'Hash')

@app.route('/run-script-compare', methods=['POST'])
def run_script_compare():
    """Execute the compare script."""
    return execute_script(SCRIPT_COMPARE_PATH, 'Compare')

@app.route('/print-log-update', methods=['post'])
def print_log_update():
    """Print the log file for the update script."""
    try:
        with open(os.path.join(os.path.dirname(__file__), '../master_scripts/update/update_logs_and_error_etc/script_output.log'), 'r') as log_file:
            return f"<h2>Update Log:</h2><pre>{log_file.read()}</pre>"
    except Exception as e:
        return f"<h2>Error:</h2><pre>{str(e)}</pre>"

@app.route('/clear-log-update', methods=['post'])
def clear_log_update():
    """Clear the log file for the update script."""
    try:
        with open(os.path.join(os.path.dirname(__file__), '../master_scripts/update/update_logs_and_error_etc/script_output.log'), 'w') as log_file:
            log_file.write('')
        return "<h2>Update Log Cleared</h2>"
    except Exception as e:
        return f"<h2>Error:</h2><pre>{str(e)}</pre>"

@app.route('/print-error-update', methods=['post'])
def print_error_update():
    """Print the error file for the update script."""
    try:
        with open(os.path.join(os.path.dirname(__file__), '../master_scripts/update/update_logs_and_error_etc/error_log.txt'), 'r') as log_file:
            return f"<h2>Update Error:</h2><pre>{log_file.read()}</pre>"
    except Exception as e:
        return f"<h2>Error:</h2><pre>{str(e)}</pre>"
    
@app.route('/clear-error-update', methods=['post'])
def clear_error_update():
    """Clear the error file for the update script."""
    try:
        with open(os.path.join(os.path.dirname(__file__), '../master_scripts/update/update_logs_and_error_etc/error_log.txt'), 'w') as log_file:
            log_file.write('')
        return "<h2>Update Error Cleared</h2>"
    except Exception as e:
        return f"<h2>Error:</h2><pre>{str(e)}</pre>"
    
@app.route('/print-ogr2ogr-update', methods=['post'])
def print_ogr2ogr_log_update():
    """Print the ogr2ogr log file for the hash script."""
    try:
        with open(os.path.join(os.path.dirname(__file__), '../master_scripts/update/update_logs_and_error_etc/ogr2ogr_log.txt'), 'r') as log_file:
            return f"<h2>Update Ogr2ogr Log:</h2><pre>{log_file.read()}</pre>"
    except Exception as e:
        return f"<h2>Error:</h2><pre>{str(e)}</pre>"

@app.route('/clear-ogr2ogr-update', methods=['post'])
def clear_ogr2ogr_log_update():
    """Clear the ogr2ogr log file for the hash script."""
    try:
        with open(os.path.join(os.path.dirname(__file__), '../master_scripts/update/update_logs_and_error_etc/ogr2ogr_log.txt'), 'w') as log_file:
            log_file.write('')
        return "<h2>Update Ogr2ogr Log Cleared</h2>"
    except Exception as e:
        return f"<h2>Error:</h2><pre>{str(e)}</pre>"
    
@app.route('/print-log-hash', methods=['post'])
def print_log_hash():
    """Print the log file for the hash script."""
    try:
        with open(os.path.join(os.path.dirname(__file__), '../master_scripts/hashing/hash_logs_and_error_etc/hash_script_output.log'), 'r') as log_file:
            return f"<h2>Hash Log:</h2><pre>{log_file.read()}</pre>"
    except Exception as e:
        return f"<h2>Error:</h2><pre>{str(e)}</pre>"
    
@app.route('/clear-log-hash', methods=['post'])
def clear_log_hash():
    """Clear the log file for the hash script."""
    try:
        with open(os.path.join(os.path.dirname(__file__), '../master_scripts/hashing/hash_logs_and_error_etc/hash_script_output.log'), 'w') as log_file:
            log_file.write('')
        return "<h2>Hash Log Cleared</h2>"
    except Exception as e:
        return f"<h2>Error:</h2><pre>{str(e)}</pre>"
    
@app.route('/print-error-hash', methods=['post'])
def print_error_hash():
    """Print the error file for the hash script."""
    try:
        with open(os.path.join(os.path.dirname(__file__), '../master_scripts/hashing/hash_logs_and_error_etc/error_log_hash.txt'), 'r') as log_file:
            return f"<h2>Hash Error:</h2><pre>{log_file.read()}</pre>"
    except Exception as e:
        return f"<h2>Error:</h2><pre>{str(e)}</pre>"
    
@app.route('/clear-error-hash', methods=['post'])
def clear_error_hash():
    """Clear the error file for the hash script."""
    try:
        with open(os.path.join(os.path.dirname(__file__), '../master_scripts/hashing/hash_logs_and_error_etc/error_log_hash.txt'), 'w') as log_file:
            log_file.write('')
        return "<h2>Hash Error Cleared</h2>"
    except Exception as e:
        return f"<h2>Error:</h2><pre>{str(e)}</pre>"
    
@app.route('/print-log-compare', methods=['post'])
def print_log_compare():
    """Print the log file for the compare script."""
    try:
        with open(os.path.join(os.path.dirname(__file__), '../master_scripts/comparing/comparing_logs_and_error/comparing_script_output.log'), 'r') as log_file:
            return f"<h2>Compare Log:</h2><pre>{log_file.read()}</pre>"
    except Exception as e:
        return f"<h2>Error:</h2><pre>{str(e)}</pre>"
    
@app.route('/print-error-compare', methods=['post'])
def print_error_compare():
    """Print the error file for the compare script."""
    try:
        with open(os.path.join(os.path.dirname(__file__), '../master_scripts/comparing/comparing_logs_and_error/error_log_comparing.txt'), 'r') as log_file:
            return f"<h2>Compare Error:</h2><pre>{log_file.read()}</pre>"
    except Exception as e:
        return f"<h2>Error:</h2><pre>{str(e)}</pre>"
    
@app.route('/clear-log-compare', methods=['post'])
def clear_log_compare():
    """Clear the log file for the compare script."""
    try:
        with open(os.path.join(os.path.dirname(__file__), '../master_scripts/comparing/comparing_logs_and_error/comparing_script_output.log'), 'w') as log_file:
            log_file.write('')
        return "<h2>Compare Log Cleared</h2>"
    except Exception as e:
        return f"<h2>Error:</h2><pre>{str(e)}</pre>"

@app.route('/clear-error-compare', methods=['post'])
def clear_error_compare():
    """Clear the error file for the compare script."""
    try:
        with open(os.path.join(os.path.dirname(__file__), '../master_scripts/comparing/comparing_logs_and_error/error_log_comparing.txt'), 'w') as log_file:
            log_file.write('')
        return "<h2>Compare Error Cleared</h2>"
    except Exception as e:
        return f"<h2>Error:</h2><pre>{str(e)}</pre>"
    
@app.route('/comparing-results', methods=['post'])
def comparing_results():
    """Combined outputs of the compare results"""
    log_files = [
    os.path.join(os.path.dirname(__file__), '../master_scripts/comparing/comparing_results/comparison_results_kommune_forslag.csv'),
    os.path.join(os.path.dirname(__file__), '../master_scripts/comparing/comparing_results/comparison_results_kommune_vedtaget.csv'),
    os.path.join(os.path.dirname(__file__), '../master_scripts/comparing/comparing_results/comparison_results_lokal_forslag.csv'),
    os.path.join(os.path.dirname(__file__), '../master_scripts/comparing/comparing_results/comparison_results_lokal_vedtaget.csv'),
    os.path.join(os.path.dirname(__file__), '../master_scripts/comparing/comparing_results/comparison_results_zonekort_samlet.csv'),
    os.path.join(os.path.dirname(__file__), '../master_scripts/comparing/comparing_results/comparison_results_zonekort.csv')
]

    combined_output = ""
    
    for file_path in log_files:
        absolute_path = os.path.join(os.path.dirname(__file__), file_path)
        if os.path.exists(absolute_path):
            # Extract and format file name
            human_readable_name = os.path.basename(file_path).replace('.csv', '').replace('_', ' ').capitalize()
            with open(absolute_path, 'r') as file:
                combined_output += f"--- Output from {human_readable_name} ---\n"
                combined_output += file.read() + "\n\n"
        else:
            combined_output += f"--- {human_readable_name} not found ---\n\n"
            
    return f"<pre>{combined_output}</pre>"

if __name__ == '__main__':
    app.run(debug=True)
