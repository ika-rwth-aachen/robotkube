import argparse
import yaml
import subprocess
import sys

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

def check_image_pulled(node_id, image):
    try:
        # Check if the image is pulled on the node
        check_command = f"docker exec {get_node_name_by_id(node_id)} crictl images | awk 'NR>1 {{print $1\":\"$2}}'"
        check_result = subprocess.run(check_command, shell=True, check=True, capture_output=True, text=True).stdout.strip()
        if image not in check_result:
            print(f"ERROR: Image '{image}' is not pulled on node '{node_id}'. One reason could be insufficient disk space.", file=sys.stderr)
            return False
        return True
    except subprocess.CalledProcessError as e:
        print(f"Failed to check if image is pulled on node: {node_id}. Error: {e}")
        return False

def main():
    with open(args.yaml_file_path, 'r') as file:
        data = yaml.safe_load(file)

    print(f"Checking if images are pulled on K8s nodes based on the YAML file '{args.yaml_file_path}' ...")

    # Check if all images are pulled according to the YAML file
    for node_id, images in data["nodes"].items():
        for image in images:
            full_image = f"{args.registry_name}:{args.port}/{image}"
            check_image_pulled(node_id, full_image)

if __name__ == '__main__':
    main()