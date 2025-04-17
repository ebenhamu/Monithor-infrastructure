all:
  vars:
    ansible_ssh_private_key_file: ${key_name}
    ansible_user: ${ssh_user}
    ansible_python_interpreter: /usr/bin/python3
  children:
    control_plane:
      hosts:
        control_plane:
          ansible_host_private: ${control_plane_private_ips}
          ansible_host_public: ${control_plane_public_ips}
    workers:
      hosts:
%{ for i, ip_pair in worker_node_ips ~}
        worker_${i + 1}:
          ansible_host_private: ${ip_pair.private}
          ansible_host_public: ${ip_pair.public}
%{ endfor ~}
