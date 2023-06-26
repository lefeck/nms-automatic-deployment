# NMS-Automatic-Deployment

This is an NGINX Management Suite offline installation and deployment tool that gets applications up and running quickly, efficiently, and reliably, solving 
problems such as the difficulty of installing and deploying our services.

## Requirements

The NMS-Automatic-Deployment supports the following Linux distributions:

| Distribution | Version | Architecture |
|--------------|---------|--------------|
| CentOS     | 7.4 and later in the 7.x family    | x86_64       |
| Ubuntu      | 22.04   | x86_64     |

if you are have other question, you can click on the link[Technical Specifications](https://docs.nginx.com/nginx-management-suite/tech-specs/) to find out more about the features.


## Utilities required:
> expect  
> httpd-tools

## Usage

This is a basic usage, you can learn more about it.

First, you need to download the installation package to the specified directory, as follows:

* Clickhouse package: You can download it to the corresponding directory by using the command `./nms-automatic-deployment.sh clickhouse download` to the corresponding directory
* Nginx package: You can download the package by using the command`./nms-automatic-deployment.sh nginx download`to the corresponding directory.
* Nginx Plus, nim and acm packages: NGINX Management Suite is a trial version or a paid subscription application, you need to download the required installation package to the corresponding directory. [Sign up for NGINX Management Suite at MyF5](https://account.f5.com/myf5).

```shell
# This is the entire file directory hierarchy, if you want to use this script, you need to download the installation package to the corresponding directory 
# in advance, you can run the script to perform installation and deployment operations
root@ubuntu:~/nms-automatic-deployment# tree .
.
├── case
│   └── ClickHouse v23 can't start by systemctl on CentOS 7.9.md
├── LICENSE
├── nms-automatic-deployment.sh
├── pkgs
│   ├── deb
│   │   ├── ubuntu20
│   │   └── ubuntu22
│   │       ├── acm
│   │       │   ├── nginx-devportal_1.5.0.819933308~jammy_amd64.deb
│   │       │   ├── nginx-devportal-ui_1.5.0.819932824~jammy_amd64.deb
│   │       │   └── nms-api-connectivity-manager_1.5.0.819933313~jammy_amd64.deb
│   │       ├── cert
│   │       │   ├── nginx-repo.crt
│   │       │   └── nginx-repo.key
│   │       ├── clickhouse-server
│   │       │   ├── clickhouse-client_23.5.3.24_amd64.deb
│   │       │   ├── clickhouse-common-static_23.5.3.24_amd64.deb
│   │       │   └── clickhouse-server_23.5.3.24_amd64.deb
│   │       ├── nginx
│   │       ├── nginxplus
│   │       │   ├── nginx-ha-keepalived_2.2.7-3-jammy_amd64.deb
│   │       │   ├── nginx-plus_28-1-jammy_amd64.deb
│   │       │   ├── nginx-plus-module-brotli_28-1.0.0-1-jammy_amd64.deb
│   │       │   ├── nginx-plus-module-encrypted-session_28-0.09-1-jammy_amd64.deb
│   │       │   ├── nginx-plus-module-fips-check_28-0.1-2-jammy_amd64.deb
│   │       │   ├── nginx-plus-module-geoip2_28-3.4-1-jammy_amd64.deb
│   │       │   ├── nginx-plus-module-geoip_28-1-jammy_amd64.deb
│   │       │   ├── nginx-plus-module-headers-more_28-0.34-2-jammy_amd64.deb
│   │       │   ├── nginx-plus-module-image-filter_28-1-jammy_amd64.deb
│   │       │   ├── nginx-plus-module-ndk_28-0.3.2-1-jammy_amd64.deb
│   │       │   ├── nginx-plus-module-njs_28-0.7.9-1-jammy_amd64.deb
│   │       │   ├── nginx-plus-module-opentracing_28-0.27.0-1-jammy_amd64.deb
│   │       │   ├── nginx-plus-module-passenger_28-6.0.15-1-jammy_amd64.deb
│   │       │   ├── nginx-plus-module-prometheus_28-1.3.4-1-jammy_amd64.deb
│   │       │   ├── nginx-plus-module-rtmp_28-1.2.2-1-jammy_amd64.deb
│   │       │   ├── nginx-plus-module-set-misc_28-0.33-1-jammy_amd64.deb
│   │       │   ├── nginx-plus-module-subs-filter_28-0.6.4-1-jammy_amd64.deb
│   │       │   ├── nginx-plus-module-xslt_28-1-jammy_amd64.deb
│   │       │   └── nginx-sync_1.1_all.deb
│   │       └── nim
│   │           └── nms-instance-manager_2.9.1-829147369~jammy_amd64.deb
│   └── rpm
│       ├── centos7
│       │   ├── acm
│       │   │   ├── nginx-devportal-1.5.0.819933308.el7.ngx.x86_64.rpm
│       │   │   ├── nginx-devportal-ui-1.5.0.819932824.el7.ngx.x86_64.rpm
│       │   │   ├── nms-api-connectivity-manager-1.5.0.819933313.el7.ngx.x86_64.rpm
│       │   │   └── nms-instance-manager-2.9.0-812521740.el7.ngx.x86_64.rpm
│       │   ├── cert
│       │   │   ├── nginx-repo.crt
│       │   │   └── nginx-repo.key
│       │   ├── clickhouse-server
│       │   │   ├── clickhouse-client-23.2.4.12.x86_64.rpm
│       │   │   ├── clickhouse-common-static-23.2.4.12.x86_64.rpm
│       │   │   └── clickhouse-server-23.2.4.12.x86_64.rpm
│       │   ├── nginx
│       │   │   └── nginx-1.23.3-1.el7.ngx.x86_64.rpm
│       │   ├── nginxplus
│       │   │   ├── nginx-ha-keepalived-2.2.7-4.el7.ngx.x86_64.rpm
│       │   │   ├── nginx-ha-keepalived-selinux-2.2.7-4.el7.ngx.x86_64.rpm
│       │   │   ├── nginx-plus-28-1.el7.ngx.x86_64.rpm
│       │   │   ├── nginx-plus-module-auth-spnego-28-1.1.0-2.el7.ngx.x86_64.rpm
│       │   │   ├── nginx-plus-module-encrypted-session-28-0.09-1.el7.ngx.x86_64.rpm
│       │   │   ├── nginx-plus-module-fips-check-28-0.1-2.el7.ngx.x86_64.rpm
│       │   │   ├── nginx-plus-module-geoip2-28-3.4-1.el7.ngx.x86_64.rpm
│       │   │   ├── nginx-plus-module-geoip-28-1.el7.ngx.x86_64.rpm
│       │   │   ├── nginx-plus-module-headers-more-28-0.34-2.el7.ngx.x86_64.rpm
│       │   │   ├── nginx-plus-module-image-filter-28-1.el7.ngx.x86_64.rpm
│       │   │   ├── nginx-plus-module-lua-28-0.10.22-2.el7.ngx.x86_64.rpm
│       │   │   ├── nginx-plus-module-ndk-28-0.3.2-1.el7.ngx.x86_64.rpm
│       │   │   ├── nginx-plus-module-njs-28-0.7.9-1.el7.ngx.x86_64.rpm
│       │   │   ├── nginx-plus-module-opentracing-28-0.27.0-1.el7.ngx.x86_64.rpm
│       │   │   ├── nginx-plus-module-passenger-28-6.0.15-1.el7.ngx.x86_64.rpm
│       │   │   ├── nginx-plus-module-perl-28-1.el7.ngx.x86_64.rpm
│       │   │   ├── nginx-plus-module-prometheus-28-1.3.4-1.el7.ngx.noarch.rpm
│       │   │   ├── nginx-plus-module-rtmp-28-1.2.2-1.el7.ngx.x86_64.rpm
│       │   │   ├── nginx-plus-module-set-misc-28-0.33-1.el7.ngx.x86_64.rpm
│       │   │   ├── nginx-plus-module-subs-filter-28-0.6.4-1.el7.ngx.x86_64.rpm
│       │   │   ├── nginx-plus-module-xslt-28-1.el7.ngx.x86_64.rpm
│       │   │   └── nginx-sync-1.1-1.el7.ngx.noarch.rpm
│       │   └── nim
│       │       └── nms-instance-manager-2.9.0-812521740.el7.ngx.x86_64.rpm
│       └── centos8
│           ├── acm
│           │   ├── nginx-devportal-1.5.0.819933308.el7.ngx.x86_64.rpm
│           │   ├── nginx-devportal-ui-1.5.0.819932824.el7.ngx.x86_64.rpm
│           │   ├── nms-api-connectivity-manager-1.5.0.819933313.el7.ngx.x86_64.rpm
│           │   └── nms-instance-manager-2.9.0-812521740.el7.ngx.x86_64.rpm
│           ├── cert
│           │   ├── nginx-repo.crt
│           │   └── nginx-repo.key
│           ├── clickhouse-server
│           │   ├── clickhouse-client-23.2.4.12.x86_64.rpm
│           │   ├── clickhouse-common-static-23.2.4.12.x86_64.rpm
│           │   └── clickhouse-server-23.2.4.12.x86_64.rpm
│           ├── nginx
│           │   └── nginx-1.23.3-1.el7.ngx.x86_64.rpm
│           ├── nginxplus
│           │   ├── nginx-ha-keepalived-2.2.7-4.el8.ngx.x86_64.rpm
│           │   ├── nginx-ha-keepalived-selinux-2.2.7-4.el8.ngx.x86_64.rpm
│           │   ├── nginx-plus-29-1.el8.ngx.x86_64.rpm
│           │   ├── nginx-plus-module-njs-29-0.7.12-1.el8.ngx.x86_64.rpm
│           │   ├── nginx-plus-module-prometheus-29-1.3.5-1.el8.ngx.noarch.rpm
│           │   └── nginx-sync-1.1-1.el8.ngx.noarch.rpm
│           └── nim
│               └── nms-instance-manager-2.9.0-812521740.el7.ngx.x86_64.rpm
└── README.md
[root@localhost nms-automatic-deployment]# ./nms-automatic-deployment.sh -h
Usage:
  nms-automatic-deployment.sh help | -h | --help
  nms-automatic-deployment.sh clickhouse (start|stop|restart|status|install|uninstall|download)
  nms-automatic-deployment.sh nginx (start|stop|restart|status|install|uninstall|download)
  nms-automatic-deployment.sh nginxplus (start|stop|restart|status|install|uninstall)
  nms-automatic-deployment.sh nim (start|stop|restart|status|install|uninstall)
  nms-automatic-deployment.sh acm (start|stop|restart|status|install|uninstall)
  nms-automatic-deployment.sh version

Options:
  help            Show this screen.
  clickhouse      Stop, start, or check the current status of clickhouse server.
  nginx           Stop, start, or check the current status of NGINX.
  nginxplus       Stop, start, or check the current status of NGINX Plus.
  nim             Stop, start, or check the current status of NGINX Instance Manager.
  acm             Stop, start, or check the current status of NGINX Management Suite API Connectivity Manager.
  version         Show the tools version
[root@localhost nms-automatic-deployment]# ./nms-automatic-deployment.sh acm -h
Stop, start, or check current status of NGINX Management Suite API Connectivity Manager.

Usage:
  nms-automatic-deployment.sh acm (start|stop|restart|status|install|uninstall)

Options:
  start     Start NGINX Management Suite API Connectivity Manager.
  stop      Stop NGINX Management Suite API Connectivity Manager.
  restart   Restart NGINX Management Suite API Connectivity Manager.
  status    Show status of NGINX Management Suite API Connectivity Manager.
  install   deploy NGINX Management Suite API Connectivity Manager.
  uninstall uninstall NGINX Management Suite API Connectivity Manager.
```
## install acm
This is an example of deploying the acm service, as follows：
```shell
[root@localhost nms-automatic-deployment]# ./nms-automatic-deployment.sh acm install     
 clickhouse-server is installing sucessed. 
 clickhouse-server is running sucessed. 
 clickhouse-server is already running sucessed. 
 the directory /etc/nginx is not exist sucessed. 
 cp nginx-repo.key nginx-repo.crt to /etc/ssl/nginx directory sucessed. 
 nginx-plus is installing sucessed. 
 nginx-plus is running sucessed. 
 nms-instance-manager is installing sucessed. 
 nms is already running sucessed. 
 change default password for web ui login sucessed. 
 nms-api-connectivity-manager is installing sucessed. 
 nms is already running sucessed. 
 nms-api-connectivity-manager is running sucessed. 
 nginx-plus is restart sucessed. 

******************** Web Login Prompt ********************************
    Login link: https://192.168.10.179/ui/
    Username: admin
    Password: admin
******************** Web Login Prompt ********************************
 [root@localhost nms-automatic-deployment]# ss -tunlp
Netid  State      Recv-Q Send-Q                             Local Address:Port                                            Peer Address:Port              
tcp    LISTEN     0      4096                                   127.0.0.1:9009                                                       *:*                   users:(("clickhouse-serv",pid=4963,fd=428))
tcp    LISTEN     0      128                                    127.0.0.1:7890                                                       *:*                   users:(("nms-dpm",pid=5995,fd=13))
tcp    LISTEN     0      128                                    127.0.0.1:7891                                                       *:*                   users:(("nms-core",pid=6005,fd=13))
tcp    LISTEN     0      128                                    127.0.0.1:9300                                                       *:*                   users:(("nms-acm",pid=6007,fd=12))
tcp    LISTEN     0      128                                            *:22                                                         *:*                   users:(("sshd",pid=1413,fd=3))
tcp    LISTEN     0      100                                    127.0.0.1:25                                                         *:*                   users:(("master",pid=1540,fd=13))
tcp    LISTEN     0      4096                                   127.0.0.1:8123                                                       *:*                   users:(("clickhouse-serv",pid=4963,fd=426))
tcp    LISTEN     0      16384                                  127.0.0.1:4222                                                       *:*                   users:(("nms-ingestion",pid=5911,fd=9))
tcp    LISTEN     0      4096                                   127.0.0.1:9000                                                       *:*                   users:(("clickhouse-serv",pid=4963,fd=427))
tcp    LISTEN     0      16384                                  127.0.0.1:9100                                                       *:*                   users:(("nms-dpm",pid=5995,fd=17))
tcp    LISTEN     0      4096                                   127.0.0.1:9004                                                       *:*                   users:(("clickhouse-serv",pid=4963,fd=429))
tcp    LISTEN     0      4096                                   127.0.0.1:9005                                                       *:*                   users:(("clickhouse-serv",pid=4963,fd=430))
tcp    LISTEN     0      511                                            *:80                                                         *:*                   users:(("nginx",pid=5379,fd=6),("nginx",pid=5378,fd=6),("nginx",pid=5377,fd=6),("nginx",pid=5376,fd=6),("nginx",pid=5375,fd=6))
tcp    LISTEN     0      4096                                       [::1]:9009                                                    [::]:*                   users:(("clickhouse-serv",pid=4963,fd=101))
tcp    LISTEN     0      128                                         [::]:22                                                      [::]:*                   users:(("sshd",pid=1413,fd=4))
tcp    LISTEN     0      4096                                       [::1]:8123                                                    [::]:*                   users:(("clickhouse-serv",pid=4963,fd=92))
tcp    LISTEN     0      4096                                       [::1]:9000                                                    [::]:*                   users:(("clickhouse-serv",pid=4963,fd=99))
tcp    LISTEN     0      4096                                       [::1]:9004                                                    [::]:*                   users:(("clickhouse-serv",pid=4963,fd=107))
tcp    LISTEN     0      4096                                       [::1]:9005                                                    [::]:*                   users:(("clickhouse-serv",pid=4963,fd=425))
```


## Thanks

If you have any questions, you can send me an email, and I will do my best to solve it.


## License

MIT license.