import argparse
import yaml
import subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed

# Set up argument parsing
parser = argparse.ArgumentParser(description='Execute kubectl debug with dynamic image name.')
parser.add_argument('--registry_name', type=str, help='The name of the registry')
parser.add_argument('--port', type=str, help='The port of the registry')
parser.add_argument('--yaml_file_path', type=str, help='The path to the YAML file containing the names of the images per node')
args = parser.parse_args()


def get_node_name_by_id(node_id):
    try:
        # Find the K8s node based on label 'node_id'
        find_node_command = f"kubectl get nodes -l node_id={node_id} -o custom-columns=NAME:.metadata.name --no-headers"
        find_node_result = subprocess.run(find_node_command, shell=True, check=True, capture_output=True, text=True).stdout.strip()
        return find_node_result
    except subprocess.CalledProcessError as e:
        print(f"Failed to find node with node_id: {node_id}. Error: {e}")
        return None

def execute_kubectl_debug(node_id, image):
    try:
        # Execute the kubectl debug command pulling the image
        debug_command = f"kubectl debug node/{get_node_name_by_id(node_id)} --image={image} -- sh -c 'exit'"
        print(f"On node '{node_id}', pull image '{image}' ... ")
        subprocess.run(debug_command, shell=True, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except subprocess.CalledProcessError as e:
        print(f"Failed to execute debug command for node: {node_id}. Error: {e}")

def main():
    with open(args.yaml_file_path, 'r') as file:
        data = yaml.safe_load(file)

    print(f"Pre-pulling images on K8s nodes based on the YAML file '{args.yaml_file_path}' ...")

    # parallelize the image pulling process
    tasks = []
    with ThreadPoolExecutor() as executor:
        for node_id, images in data["nodes"].items():
            for image in images:
                # Execute the kubectl debug command pulling the image
                full_image = f"{args.registry_name}:{args.port}/{image}"
                tasks.append(executor.submit(execute_kubectl_debug, node_id, full_image))

        for future in as_completed(tasks):
            future.result()

if __name__ == '__main__':
    main()