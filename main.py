import time, threading, argparse
from api_avicola import api, mqtt_subscriber
from dashboard_avicola import dashboard 
from debug import simulation

def parse_args():
    parser = argparse.ArgumentParser(
        description="Poultry Monitoring System"
    )
    parser.add_argument(
        "-s", "--simulated",
        action="store_true",
        help="Enables MQTT simulation"
    )
    return parser.parse_args()

def run_api():
    """Runs the API Flask"""
    print("Starting API...")
    try:
        api.start(port=5000, host='0.0.0.0')  
    except Exception as e:
        print(f"Error: {e}")

def run_dashboard():
    """Runs the Dashboard Flask"""
    print("Starting DASHBOARD...")
    try:
        dashboard.start(port=5001, host='0.0.0.0') 
    except Exception as e:
        print(f"Error: {e}")

def run_mqtt_subscriber():
    """Runs the MQTT subscriber"""
    print("Starting MQTT SUBSCRIBER...")
    try:
        mqtt_subscriber.start()
    except Exception as e:
        print(f"Error: {e}")

def run_simulation():
    """Runs the simulation"""
    print("Starting SIMULATION...")
    try:
        simulation.start()
    except Exception as e:
        print(f"Error: {e}")


def main(use_simulation: bool = False):

    print("Starting POULTRY MONITORING SYSTEM...")
    print(f"Mode: {'SIMULATED' if use_simulation else 'REAL'}")

    # Start threads 
    api_thread = threading.Thread(target=run_api, daemon=True)
    dashboard_thread = threading.Thread(target=run_dashboard, daemon=True)
    mqtt_thread = threading.Thread(target=run_mqtt_subscriber, daemon=True)
    if use_simulation:
        simulation_thread = threading.Thread(target=run_simulation, daemon=True)
    else:
        simulation_thread = None

    api_thread.start()
    dashboard_thread.start()
    mqtt_thread.start()
    if simulation_thread:
        simulation_thread.start()



    # Keep the main thread running
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\nStopping all services...")
        print("System stopped successfully")


if __name__ == "__main__":
    args = parse_args()
    # default mode = real 
    main(use_simulation=args.simulated)
