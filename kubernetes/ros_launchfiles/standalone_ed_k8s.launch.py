from ament_index_python import get_package_share_directory
from launch import LaunchDescription

from launch.actions import DeclareLaunchArgument, GroupAction
from launch.conditions import LaunchConfigurationNotEquals
from launch.substitutions import LaunchConfiguration, PathJoinSubstitution

from launch_ros.actions import LifecycleNode, SetParameter


def generate_launch_description():

    params_arg = DeclareLaunchArgument('params', default_value=PathJoinSubstitution([
        get_package_share_directory("event_detector"), "config", "params_k8s_rule.yml"])
    )

    node_name_default = 'event_detector'
    node_name_arg = DeclareLaunchArgument('node_name',
                                          default_value=node_name_default)

    startup_state_arg = DeclareLaunchArgument('startup_state', default_value='None')

    # node
    node = LifecycleNode(
        name=LaunchConfiguration('node_name'),
        namespace='',
        package='event_detector',
        executable='event_detector',
        parameters=[LaunchConfiguration('params')],
        output='screen',
        emulate_tty=True)

    # set startup_state, if it was given
    node_group = GroupAction(
        actions=[
            SetParameter(name='startup_state',
                         value=LaunchConfiguration('startup_state'),
                         condition=LaunchConfigurationNotEquals('startup_state', "None")),
            node
        ]
    )

    return LaunchDescription([
        params_arg,
        node_name_arg,
        startup_state_arg,
        node_group
    ])
