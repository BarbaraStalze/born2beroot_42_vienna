*This project has been created as part of the 42 curriculum by bastalze.*

# Born2beroot

## Description

Born2beroot is a project focused on system administration, virtualization and server security. The goal is to set up a **minimal, stable, and secure** server by installing a Linux distribution (either **Debian** or **Rocky**) in a virtual machine, while following strict guidelines.

The project involves:
- Initial installation and manual partitioning of the system
- Implementation of a robust **password policy** and user/group management
- Configuration of **sudo** with strict rules
- Setting up a **firewall** and an **intrusion detection system** (`sshguard`)
- Installation and configuration of a **mandatory access control** system (SELinux or AppArmor)
- Automation of system monitoring via a custom script

This project provides hands-on experience in server hardening, service management and understanding fundamental Linux security mechanisms.

## Project Description & Design Choices

### Operating System Choice: Debian vs Rocky Linux

I chose **Debian** for this project. Below is a comparison of the two options:

| Aspect | **Debian** | **Rocky Linux** |
|--------|------------|-----------------|
| **Philosophy** | Community-driven, stable, free software | Enterprise-grade, binary-compatible rebuild of RHEL |
| **Package Management** | `apt` / `.deb` packages. Large repositories | `dnf` / `.rpm` packages. Relies on EPEL for broader software |
| **Stability** | Extremely stable due to lengthy testing cycles | Very stable, follows RHEL's lifecycle (10-year support) |
| **Release Cycle** | Slow (2-3 years) | Predictable, tied to RHEL releases |
| **Ease of Use** | Slightly easier for beginners, extensive documentation | More enterprise-focused, may have a steeper initial curve |
| **Project Fit** | Ideal for learning universal Linux admin with `apt`. Excellent stability for a server | Ideal for learning Red Hat ecosystem tools (e.g., `firewalld`, SELinux in strict mode) |

**Why Debian?**
Its stability, vast package repositories, and widespread use in production servers make it an excellent learning platform. The `apt` package manager is intuitive, and the project's requirements are perfectly met by Debian's long-term support model.

### Main Design Choices During Setup

1. **Partitioning:** Used **LVM (Logical Volume Manager)** with manual partitioning to create separate mounts for `/`, `/home`, `/var`, `/var/tmp`, and `/boot`. This provides flexibility for resizing partitions later and follows good practice for isolating directories with high write activity.

2. **Security Policies:**
   - Implemented a strong password policy via `/etc/login.defs` and `pam_pwquality`
   - Configured **sudo** with a dedicated group (`sudo` or `wheel`) and restricted privileges in `/etc/sudoers.d/`
   - Set up **cron jobs** for regular system updates and monitoring script execution

3. **User Management:** Created a user with low privileges and added them to the sudo group. A separate user was created for the monitoring script (`monitor`).

4. **Services Installed:**
   - **SSH:** Configured to run on a non-default port (e.g., 4242) with password authentication disabled for sudo users (key-based only)
   - **Fail2ban:** To protect SSH from brute-force attacks
   - **UFW:** A simple firewall to allow only necessary ports (SSH, HTTP, HTTPS)
   - **AppArmor:** The chosen MAC system for Debian

### Technology Comparisons

#### AppArmor vs SELinux

| Feature | **AppArmor** | **SELinux** |
|---------|--------------|-------------|
| **Model** | Path-based, application-centric | Label-based, system-wide mandatory access control |
| **Configuration** | Profiles are generally simpler to understand and modify | Uses complex security contexts, policies, and booleans. Steeper learning curve |
| **Default on** | Debian, Ubuntu, openSUSE | RHEL, Rocky, Fedora, CentOS |
| **Ease of Use** | More straightforward for common applications | More powerful and granular, but harder to debug and configure |
| **Choice Rationale** | Chosen for Debian. Its path-based model is easier to manage for a learning project while still providing strong security for defined services | Required if using Rocky. More appropriate for high-security, multi-user enterprise environments |

#### UFW vs firewalld

| Feature | **UFW (Uncomplicated Firewall)** | **firewalld** |
|---------|----------------------------------|---------------|
| **Backend** | Frontend for `iptables`/`nftables` | Frontend with dynamic management, uses zones and services |
| **Complexity** | Simpler, designed for ease of use | More feature-rich, designed for complex network environments (e.g., laptops moving between networks) |
| **Default on** | Debian, Ubuntu | RHEL, Rocky, Fedora |
| **Configuration** | Command-line (`ufw allow <port>`), simple config files | Command-line (`firewall-cmd`), graphical tools, XML configuration files |
| **Choice Rationale** | Perfectly suited for a static server. Its simplicity aligns with the project's goal of creating a clear and maintainable configuration | The natural choice for Rocky/RHEL systems. More abstract and powerful |

#### VirtualBox vs UTM (for macOS)

| Feature | **VirtualBox** | **UTM** (macOS) |
|---------|----------------|-----------------|
| **Type** | Type-2 Hypervisor | Type-2 Hypervisor (uses Apple's Hypervisor.framework on ARM) |
| **Host OS** | Windows, Linux, macOS (Intel) | Primarily macOS (both Intel and Apple Silicon) |
| **Performance** | Good, mature. On macOS Apple Silicon, requires ARM OS images | Excellent on Apple Silicon due to native virtualization support |
| **Ease of Use** | Very mature, feature-rich (snapshots, shared folders) | Clean, modern interface on macOS. Simpler but less feature-dense |
| **Project Suitability** | Cross-platform standard, well-documented. Perfectly suitable, especially on Intel | Excellent choice for Apple Silicon Macs, as it natively supports ARM VMs (required for Debian/Rocky ARM images) |

**Note:** On modern Apple Silicon Macs, UTM (or VMware Fusion) is often the better choice due to native ARM virtualization. VirtualBox for ARM is less mature.

## Instructions

### Prerequisites
- A virtualization software (VirtualBox, UTM, or VMware)
- The installation ISO for **Debian** (NetInstall minimal image recommended)

### Installation & Setup
1. **Create VM:** Allocate minimal resources (e.g., 1 core, 1024MB RAM, 8GB dynamic disk)
2. **Install OS:** During installation:
   - Choose **manual partitioning** and set up **LVM**
   - Create the required partitions (`/boot`, `/`, `/home`, `/var`, `/var/tmp`)
   - Install only the SSH server and standard system utilities
3. **Post-Install Configuration:**
   - Update packages: `sudo apt update && sudo apt upgrade -y`
   - Install required packages: `sudo`, `ufw`, `fail2ban`, `libpam-pwquality`, `apparmor`, `apparmor-utils`, `cron`, `vim` (or `nano`)
   - Configure the password policy in `/etc/login.defs` and `/etc/security/pwquality.conf`
   - Set up sudo according to specifications
   - Configure SSH: change port, disable root login, enforce key-based auth
   - Enable and configure UFW: `sudo ufw allow 4242/tcp` (SSH), enable logging, activate
   - Configure AppArmor: ensure it's running and enforce mode for critical profiles
   - Deploy the monitoring script (`monitoring.sh`) and set a cron job to run it every 10 minutes

### Execution
- Connect via SSH: `ssh user@<vm_ip> -p 4242`
- The monitoring script can be executed manually: `sudo bash /path/to/monitoring.sh`

## Resources

### References
- **Born2BeRoot guide sourced by gemartin99** https://noreply.gitbook.io/born2beroot
- **For monitoring.sh bash skript:** 
https://askubuntu.com/questions/1292702/how-to-get-number-of-phy-logical-cores
https://stackoverflow.com/questions/4538253/how-can-i-exclude-one-word-with-grep
https://serverfault.com/questions/69283/when-to-use-single-quotes-double-quotes-or-no-quotes-in-grep

### Peers
Kian helped me with every question I had regarding the project. Anna sent me the guide and did the project paralell to me for emotional support.

### AI Usage Statement
Artificial Intelligence (specifically DeepSeek) was used as a tool during this project in the following ways:

- **Concept Clarification:** To understand and compare technical concepts (e.g., differences between AppArmor and SELinux, LVM partitioning logic)
- **Command & Syntax Help:** For finding correct command-line options or configuration file syntax for tools like `ufw`, `cron`, and `pam_pwquality`
- **Troubleshooting:** To generate debugging steps for common errors during package installation or service configuration
- **Documentation Structuring:** To brainstorm the organization and content for this README file
