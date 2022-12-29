# netblock

## Definition
**netblock** is a simple client to consume `whois.pwhois.org` service written in **Ruby**. More info [here](https://pwhois.org/).

## Install
1. `git clone https://github.com/p0ngbr/netblock.git`
2. `cd netblock`
3. `./netblock`
4. Enjoy!

## Development
**netblock** is under development (to improve my Ruby skills). So bugs are expected.

## Usage
#### Search using provider (or part of it) name
```
$ ./netblock "University of Michigan"
       ASN │ Provider name
   AS36375 │ University of Michigan
   AS62676 │ University of Michigan - Dearborn
  AS394769 │ University of Michigan - Flint
 INFO  Found: 3
```

#### Search using ASN code directly
```
$ ./netblock AS36375
             ASN │ AS36375
        Provider │ University of Michigan
        Netblock │ 35.0.0.0-35.0.255.255 35.1.0.0-35.1.255.255 35.2.0.0-35.2.255.255 35.3.0.0-35.3.255.255 35.4.0.0-35.4.255.255 35.5.0.0-35.5.255.255 35.6.0.0-35.6.255.255 35.7.0.0-35.7.255.255 35.7.0.0-35.7.63.255 35.7.128.0-35.7.191.255 67.194.0.0-67.194.255.255 192.41.230.0-192.41.231.255 192.41.232.0-192.41.233.255 192.41.236.0-192.41.237.255 192.206.53.0-192.206.53.255 198.108.8.0-198.108.15.255 198.111.224.0-198.111.227.255 207.72.6.0-207.72.6.15 207.75.144.0-207.75.159.255
     Total IP(s) │ 631,568
```

#### Search using IP address (IPv4 only)
```
$ ./netblock 35.7.128.0
             ASN │ AS36375
        Provider │ University of Michigan
        IP block │ 35.7.0.0-35.7.255.25535.7.128.0-35.7.191.255
        Netblock │ 35.0.0.0-35.0.255.255 35.1.0.0-35.1.255.255 35.2.0.0-35.2.255.255 35.3.0.0-35.3.255.255 35.4.0.0-35.4.255.255 35.5.0.0-35.5.255.255 35.6.0.0-35.6.255.255 35.7.0.0-35.7.255.255 35.7.0.0-35.7.63.255 35.7.128.0-35.7.191.255 67.194.0.0-67.194.255.255 192.41.230.0-192.41.231.255 192.41.232.0-192.41.233.255 192.41.236.0-192.41.237.255 192.206.53.0-192.206.53.255 198.108.8.0-198.108.15.255 198.111.224.0-198.111.227.255 207.72.6.0-207.72.6.15 207.75.144.0-207.75.159.255
     Total IP(s) │ 631,568
```
#### What is currently working?
- [x] IP search (IPv4)
- [x] Provider search
- [x] ASN search
#### What is not (yet) currently working?
- [ ] Advanced search (IP, provider and ASN info)
- [ ] Output to file
