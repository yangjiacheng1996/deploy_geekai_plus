# deploy_geekai_plus
对geekai-plus项目进行改造，使其更容易维护

# geekai-plus原项目
1. 项目地址： https://github.com/yangjian102621/geekai-plus
2. 项目结构：
```
{ROOT}/conf: mj-proxy/, mysql/, nginx, xxl-job, config-toml
{ROOT}/data/mysql： init.d/, update/
{ROOT}/imgs:  一堆png图片。
{ROOT}/docker-compose.yaml
```
3.官方文档：  https://docs.geekai.me/

# 本项目的结构
原作者将所有服务写入一个yaml，如果任何一个服务需要重启，都将重启整个集群，用户侧有感，服务出现卡顿和断连。作者在官方文档中也建议，将每个服务拆开，单独成一个yaml，最简单粗暴的方式是clone出5份项目。
我的项目结构如下：
```
{ROOT}/mysql/：
    my.cnf , 来自原项目./conf/mysql/my.cnf;
    init.d/ , 来自原项目./data/mysql/init.d/;
    update/ , 来自原项目./data/mysql/update;
    data/ , 容器映射，无需手动创建;
    logs/ , 容器映射，无需手动创建;

{ROOT}/redis/：
    data/ , 容器映射，无需手动创建;

{ROOT}/tika/：无数据卷映射;

{ROOT}/api/：
    config.toml , 来自原项目./conf/config.toml;
    logs/ , 容器映射，无需手动创建;
    static/ , 容器映射，无需手动创建;
    leveldb/ , 容器映射，无需手动创建;

{ROOT}/nginx/：
    logs/ , 容器映射，无需手动创建;
    conf.d , 来自原项目./conf/nginx/conf.d;
    nginx.conf , 来自原项目./conf/nginx/nginx.conf;
    ssl/ , 容器映射，无需手动创建;

{ROOT}/xxl/:
    logs/ , 容器映射，无需手动创建;
    application.properties , 来自原项目./conf/xxl-job/application.properties

{ROOT}/mj-proxy/：
    config/application.yml , 来自原项目./conf/mj-proxy/application.yml

{ROOT}/install.sh: 本人定制了一个安装脚本。因为服务拆开后，depends_on服务间依赖关系被删除，所以考一个shell脚本来维护服务启停顺序。
```

# 网络安全
原作者的docker-compose文件中，所有容器都做了端口映射。如果生产环境也进行容器映射，则集群多个端口暴露在公网下，容易被攻击导致生产崩溃，任何人访问可以扫描服务器端口，对数据库和redis进行root密码暴力破解。有哪些解决方法：
1. 服务器安全组添加规则，拒绝外部访问集群端口。此方案不可行，如果容器不处于同一个docker网桥，将导致容器通信中断。
2. 创建一个独立的docker网桥，所有容器处于这个网桥下，容器间通信依靠主机名。此方案可行，本项目采用这个方案。
3. 采用公网NAT网关。将服务器放到公网NAT网关中，服务器可以访问外部网络，外部无法访问服务器。不添加任何安全组规则，可随意进行端口映射。最躺平的玩法，缺点是贵，看看阿里云公网NAT的价格先！

在部署本项目前，脚本通过docker network create geekai_plus_network命令创建一个网桥，在config.toml中全部采用容器名通信，yaml文件中取消所有端口映射，请不要随意修改容器名！

# 高可用
建议使用Kubernetes部署高可用生产，每个服务都是无状态deployment，配置文件config.toml中的主机名填写Kubernetes的SVC地址。
1. 集群入口：可以采用负载均衡或防火墙。负载均衡包括硬件F5、阿里云SLB等等。免费防火墙可以使用南墙uuwaf。
2. web多副本：进入负载均衡或防火墙的流量紧接着会进入web应用，本项目的web应用本身是个nginx，属于无状态服务，可以部署多个。
3. api多副本: 与原作者沟通得知，本项目的api服务也是无状态，用户登录的会话共享，redis缓存了用户状态，所以可以多副本扩容。
4. redis：可以多分片部署，或者直接购买阿里云的redis集群。
5. mysql：可以主备部署，或者购买阿里云RDS或者分布式数据库。
6. tika：这是一个读取pdf、excel的容器，本身是开源的Apache tika项目。这个项目本身就是无状态的，可以多副本扩容。

什么时候高可用：如果你的生产环境最高并发小于1000，那么只需要8核心的独立主机即可，省钱。超过1000并发，这意味着你已经从这个项目赚到钱了，日活资金可以支撑你上阿里云，买Kubernetes（ACK）！

