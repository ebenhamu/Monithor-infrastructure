all:
  vars:
    ansible_ssh_private_key_file: ${key_name}
    ansible_user: ${ssh_user}
    ansible_python_interpreter: /usr/bin/python3
  children:
    control_plane:
      hosts:
        control_plane:
          ${control_plane_name_prefix}_private: ${control_plane_private_ips}
          ${control_plane_name_prefix}_public: ${control_plane_public_ips}
    workers:
      hosts:
    %{ for i, ip_pair in worker_node_ips ~}
        worker_${i + 1}:
          ${worker_name_prefix}_${i+1}_private: ${ip_pair.private}
          ${worker_name_prefix}_${i+1}_public: ${ip_pair.public}
    %{ endfor ~}

