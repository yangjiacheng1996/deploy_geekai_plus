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

