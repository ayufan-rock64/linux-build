# Use NordVPN

It is possible to use NordVPN on Rock64/RockPro64/Pinebook Pro
boards with ease, either with OpenVPN or Wireguard.

## Install NordVPN client

First you have to install NordVPN client:

```bash
sudo wget -qnc https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn-release_1.0.0_all.deb
sudo dpkg -i nordvpn-release_1.0.0_all.deb
sudo apt update -y
sudo apt install -y nordvpn
```

## Connecting to VPN

Once you have everything installed connecting is super simple:

```bash
sudo nordvpn connect

Please enter your login details.
Email / Username: USER@EMAIL
Password: PASSWORD
Welcome to NordVPN! You can now connect to VPN by using 'nordvpn connect'.
Connecting to Poland #88 (pl88.nordvpn.com)
You are connected to Poland #88 (pl88.nordvpn.com)!
```

## Using Kill Switch and Auto Connect

One of the potential use-cases for NordVPN is to use it
on OpenMediaVault. You might want to configure `Kill Switch`,
`Auto-Connect` and whitelist your network to be able to
access the host. Consider doing that before connecting,
as if you connect you will might lose access to board
over SSH or Web browser:

```bash
nordvpn whitelist add port 22
Port 22 (UDP|TCP) is whitelisted successfully.
```

```bash
nordvpn whitelist add subnet 192.168.88.0/24
Subnet 192.168.88.0/24 is whitelisted successfully.
```

```bash
nordvpn set autoconnect on
Auto-connect is set to 'enabled' successfully.
```

```bash
nordvpn set killswitch on
Kill Switch is set to 'enabled' successfully.
```

## Using Wireguard / NordLynx

NordVPN allows you to use [Wireguard](https://www.wireguard.com/).
Wireguard performance is superb on the board, and substentianonaly
better than that of OpenVPN (OpenVPN is used by default).

It is advised to configure `Wireguard`.
You can follow the installation guide by
checking out the [Wireguard / DKMS](dkms.md).

Once you follow all steps (ensure that you follow them in order),
simply change to use `NordLynx`:

```bash
nordvpn set technology NordLynx
Technology is successfully set to 'NordLynx'.
```

You will now connect using `Wireguard`.
