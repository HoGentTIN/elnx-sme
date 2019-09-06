# Putting it all together: gateway & DHCP

## Learning goals

- Being able to set up a DHCP server for a small network
    - Understanding the configuration of DHCP and being able to adapt it for a specific situation
    - Assign basic network configuration settings to clients: IP address and subnet mask, default gateway, DNS servers
    - Setting up subnets and pools of dynamic IP addresses
    - Assign a reserved IP address based on MAC address
    - Configuring the lease time
- Being able to set up a router with VyOS
    - Configure network interfaces
    - Configure Network Address Translation
    - Set up a DNS forwarder

## Assignment

In this assignment, the goal is to complete the network we've been building with a DHCP server for workstations and a router. When a workstation is attached to the network, it should receive correct network settings from the DHCP server (IP address, default gateway, DNS) and be able to use the services on the local network (specifically the webserver and fileserver) and to access the Internet through the router.

### Router and DNS resolver

The Vagrant configuration for the router is already provided (in `Vagrantfile`), and is considerably different from the others. You should install a plugin that adds support for VyOS to Vagrant with `vagrant plugin install vagrant-vyos`. `vagrant status` should show the router, and you should be able to boot it.

The router runs a specialized Linux distribution, [VyOS](http://vyos.net/). VyOS is partly inspired by Cisco's IOS, so the workflow and commands may be a bit familiar. First, [make yourself acquainted](https://github.com/bertvv/cheat-sheets/blob/master/docs/VyOS.md) with the configuration commands.

An overview of the network interfaces:

| Interface | VBox adapter | IP address          | Remarks  |
| :---      | :---         | :---                | :---     |
| `eth0`    | NAT          | 10.0.2.15/24 (DHCP) | WAN link |
| `eth1`    | Host-only    | 192.0.2.254/24      | DMZ      |
| `eth2`    | Host-only    | 172.16.255.254/16   | internal |

- The configuration of the VyOS router is not done through Ansible, but with a shell script, `scripts/router-config.sh`. Some scaffolding code is already present in the script, with comments that explain which settings to be added.
- Configure the network interfaces, ensure `eth0` is used as WAN link. The network configuration settings (IP address, gateway, DNS server) on this interface were assigned by the VirtualBox NAT interface. Assume these addresses were provided by Avalon's Internet Service Provider. Network traffic from the local network to the Internet should be forwarded to the correct IP address (the ISP's gateway).
- This router is also configured as a **forwarding DNS server** to be used by your workstations. This means that it does not have its own zone definitions, but it forwards all requests to appropriate name servers:
    - DNS requests for the `avalon.lan` domain are forwarded to the authoritative name server you set up in a previous assignment (remark that VyOS only allows to set a single DNS server per domain for forwarding);
    - All other DNS requests are forwarded to the appropriate IP address (the DNS server assigned by the "ISP"). **Do not use Google's DNS servers or other public DNS resolvers!**
- The internal network has a private IP range that should not be routed to the external network. Set up Network Address Translation for all traffic originating from the internal network and directed either to the WAN/Internet or the DMZ.
- For synchronizing the system clock, most computer systems use NTP (Network Time Protocol). Delete the default NTP servers, and use the pool zone for your location (e.g. [be.pool.ntp.org](http://www.pool.ntp.org/zone/be) for Belgium). Also, set the time zone.

### DHCP

Known hosts (workstations) should receive a reserved IP address based on their MAC address and should get a lease time of 12 hours. Hosts that do not have their MAC address registered (guests) should get a dynamically assigned IP address, with a lease time of 4 hours.

The address space of the internal network is used as follows:

| Lowest address | Highest address | Host type                    |
| :---           | :---            | :---                         |
| 172.16.0.1     | --              | VirtualBox host system       |
| 172.16.0.2     | 172.16.127.254  | Guests (dynamic IP)          |
| 172.16.128.1   | 172.16.191.254  | Worksations (reserved IP)    |
| 172.16.192.1   | 172.16.255.254  | Servers, gateway (static IP) |

Some remarks:

- Only hosts with a dynamic or reserved IP address are assigned by the DHCP server!
- Beware of the DNS settings your DHCP server provides to workstations and guest pc's! Guest pc's should be able to access both internal services as the Internet!

## Acceptance test

There are no automated tests for validating the DHCP server, so you need to use a manual procedure. A good test plan is important! Describe a detailed procedure with specific commands to use or actions to take in order to prove that the specifications are met, including expected results.

Some suggestions:

- Create a new VirtualBox VM manually, give it two host-only network interfaces, both attached to the VirtualBox host-only network with IP 172.16.0.0/16.
    - Write down the MAC address of one of the two interfaces (or set it manually, e.g. "DE:AD:C0:DE:CA:FE"), and ensure the DHCP gives that host a reserved IP address from the correct address range.
    - Both network interfaces can be attached at the same time, but you could disconnect the cable of one
- Boot the VM with a LiveCD ISO (e.g. Fedora, but Ubuntu, Kali, etc. should also be fine).

Things to check (follow the guidelines for bottom-up troubleshooting!):

- **Network access layer**
    - Is the workstation connected to the correct VirtualBox Host-only network?
    - Is any NAT or bridged interface disabled (or cable disconnected)?
- **Internet layer**
    - Did the VM receive correct IP settings from the DHCP server?
        - IP address in the correct range for either guest with dynamic IP or reserved IP?
        - Correct subnet mask?
        - DNS server?
        - Default gateway?
    - LAN connectivity: can you ping
        - other hosts in the same network?
        - the gateway? All its IP addresses?
        - a host in the DMZ?
        - the default gateway of the router?
    - Is the DNS server responsive?
        - does it resolve www.avalon.lan?
            - does it resolve an external name? (e.g. www.google.com, icanhazip.com)
        - does it resolve reverse lookups for avalon.lan? (e.g. 192.0.2.10, 172.16.192.1)
- **Transport layer**
    - Not applicable, as no services run on the workstation
- **Application layer**: Are network services available?
    - Is <http://www.avalon.lan/wordpress/> visible?
    - Is an external website, e.g. <http://icanhazip.com/>, visible?
    - is the fileserver available? e.g. smb://files/public or `ftp files.avalon.lan`.
