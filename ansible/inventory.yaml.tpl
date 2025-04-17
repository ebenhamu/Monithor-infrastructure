control_plane:
  private_ips:
    - ${control_plane_private_ips}
  public_ips:
    - ${control_plane_public_ips}

workers:
  private_ips:
    - ${worker_private_ips}
  public_ips:
    - ${worker_public_ips}

ssh_config:
  key_name: ${key_name}
  user: ${ssh_user}
