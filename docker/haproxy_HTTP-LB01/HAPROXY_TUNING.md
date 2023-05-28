# Tunings feitos no HAproxy

Algumas otimizações e mudanças em semaforos de kernel para cenários extremos (benchmarks por exemplo).

## Sysctl

Parametros sysctl comuns em ambientes com HAproxy Enterprise (tuning basico e ponto inicial de partida).

```
# Limit the per-socket default receive/send buffers to limit memory usage
# when running with a lot of concurrent connections. Values are in bytes
# and represent minimum, default and maximum. Defaults: 4096 87380 4194304
#
#net.ipv4.tcp_rmem            = 8192 174760 8388608
#net.ipv4.tcp_wmem            = 8192 174760 8388608

# Allow early reuse of a same source port for outgoing connections. It is
# required above a few hundred connections per second. Defaults: 0
#
# net.ipv4.tcp_tw_reuse        = 1

# Extend the source port range for outgoing TCP connections. This limits early
# port reuse and makes use of 64000 source ports. Defaults: 32768 61000
#
# net.ipv4.ip_local_port_range = 1024 65023

# Increase the TCP SYN backlog size. This is generally required to support very
# high connection rates as well as to resist SYN flood attacks. Setting it too
# high will delay SYN cookie usage though. Defaults: 1024
#
# net.ipv4.tcp_max_syn_backlog = 60000

# Timeout in seconds for the TCP FIN_WAIT state. Lowering it speeds up release
# of dead connections, though it will cause issues below 25-30 seconds. It is
# preferable not to change it if possible. Default: 60
#
# net.ipv4.tcp_fin_timeout     = 30

# Limit the number of outgoing SYN-ACK retries. This value is a direct
# amplification factor of SYN floods, so it is important to keep it reasonably
# low. However, too low will prevent clients on lossy networks from connecting.
# Using 3 as a default value gives good results (4 SYN-ACK total) and lowering
# it to 1 under SYN flood attack can save a lot of bandwidth. Default: 5
#
# net.ipv4.tcp_synack_retries  = 3

# Set this to one to allow local processes to bind to an IP which is not yet
# present on the system. This is typically what happens with a shared VRRP
# address, where you want both primary and backup to be started even though the
# IP is not yet present. Always leave it to 1. Default: 0
#
# net.ipv4.ip_nonlocal_bind    = 1

# Serves as a higher bound for all of the system's SYN backlogs. Put it at
# least as high as tcp_max_syn_backlog, otherwise clients may experience
# difficulties to connect at high rates or under SYN attacks. Default: 128
#
# net.core.somaxconn           = 60000
```
Descomentar cada parametro de kernel na medida do necessário.

Fonte: [HAproxy Docs](https://www.haproxy.com/documentation/hapee/latest/getting-started/system-tuning/)

## Sysctl para liberar net tables limites em kerneis Linux

```
## Tuning para altos limites de trafego de rede
net.netfilter.nf_conntrack_max = 2000000
net.netfilter.nf_conntrack_buckets = 2000000
net.core.message_cost=0
```

Dos parametros acima, o unico que não trata trafego é o net.core.message_cost, sendo que este é para liberar o limite de call simultaneas em serviços como o syslog. Em ambientes HAproxy com muito trafego e registro de logs esse parametro ajuda a manter limpo o syslog out (e principalmente o messages/dmesg).

## Sysctl para alocar porta privilegiada (portas abaixo de 1024)

```
## Alocacao de Porta privilegiada baixa (default 1024)
net.ipv4.ip_unprivileged_port_start = 0
```

Este parameto é importante em cenários HTTP e TCP do Haproxy, onde pode ser necessário alocar portas baixas como 80, 443, 22, 21, etc...

## Persistencia sysctl

Em ambientes Alpine Linux, foi necessário ativar o modulo **nf_conntrack** no boot para que os parametros adicionados via _/etc/sysctl.d_ funcionem durante o carregamento do linux.

```bash
echo 'nf_conntrack' >> /etc/modules
```

## Dimensionamento do server com HAproxy

Apesar do HAproxy ser extremamente leve, consumindo pouquissimos recursos de CPU e RAM, a quantidade de cada um influencia em alguns parametros dinamicos, tanto de kernel linux quanto do HAproxy. Recomendado variar a quantidade de CPU/RAM e validar em cada situação. Aqui uma base de comparação em testes reais no cluster Vmware em um cenário de HAproxy unico com 5 backends **nginxdemos/hello**.

1. 8vcpu/4Gb

```
Concurrency Level:      100
Time taken for tests:   16.496 seconds
Complete requests:      500000
Failed requests:        0
Total transferred:      3702500000 bytes
HTML transferred:       3609000000 bytes
Requests per second:    30309.51 [#/sec] (mean)
Time per request:       3.299 [ms] (mean)
Time per request:       0.033 [ms] (mean, across all concurrent requests)
Transfer rate:          219181.57 [Kbytes/sec] received
```

Throughput no HAproxy: 2,11 Gbps

2. 4vcpu/4Gb

```
Concurrency Level:      100
Time taken for tests:   17.757 seconds
Complete requests:      500000
Failed requests:        0
Total transferred:      3702500000 bytes
HTML transferred:       3609000000 bytes
Requests per second:    28157.55 [#/sec] (mean)
Time per request:       3.551 [ms] (mean)
Time per request:       0.036 [ms] (mean, across all concurrent requests)
Transfer rate:          203619.76 [Kbytes/sec] received
```
Throughput no HAproxy: 1,84 Gbps

3. 4vcpu/2Gb

```
Concurrency Level:      100
Time taken for tests:   17.916 seconds
Complete requests:      500000
Failed requests:        0
Total transferred:      3702500000 bytes
HTML transferred:       3609000000 bytes
Requests per second:    27908.28 [#/sec] (mean)
Time per request:       3.583 [ms] (mean)
Time per request:       0.036 [ms] (mean, across all concurrent requests)
Transfer rate:          201817.19 [Kbytes/sec] received
```

Throughput no HAproxy: 1,80 Gbps

4. 1vcpu/2Gb

```
Concurrency Level:      100
Time taken for tests:   54.434 seconds
Complete requests:      500000
Failed requests:        0
Total transferred:      3702500000 bytes
HTML transferred:       3609000000 bytes
Requests per second:    9185.48 [#/sec] (mean)
Time per request:       10.887 [ms] (mean)
Time per request:       0.109 [ms] (mean, across all concurrent requests)
Transfer rate:          66424.28 [Kbytes/sec] received

```

Throughput no HAproxy: 0,59 Gbps

## SSL Termination

Os testes foram executados também com o SSl termination ligado no HAproxy. Dessa forma, o acesso ao balancer é fechado via HTTPs e dele pros backends sem SSL. A queda de performance é expressiva:

4vcpu/1Gb

```
Concurrency Level:      200
Time taken for tests:   591.834 seconds
Complete requests:      1000000
Failed requests:        0
Total transferred:      7424000000 bytes
HTML transferred:       7237000000 bytes
Requests per second:    1689.66 [#/sec] (mean)
Time per request:       118.367 [ms] (mean)
Time per request:       0.592 [ms] (mean, across all concurrent requests)
Transfer rate:          12250.05 [Kbytes/sec] received
```

Throughput no HAproxy: 0,18 Gbps

## Global Logging

O recurso de logging de trafego do HAproxy também representou penaltes em performance durante os testes. O mesmo ambiente que suportou 30 mil requests por segundo e 2Gbps, caiu para 20 mil requests e cerca de 1,4Gbps. Vale um tuning fino no que é logado por padrão em cada front para isolar a parda de performance em situações que se precisa de alto throughput.

# Conclusão

Os testes acima mostram que o HAproxy, com um tuning basico, consegue cerca de 10000 requests por segundo por cada vcpu até uma marca de 30000 quando certamente esbarra em outras limitações como de semaforos do kernel, IPC de cada vcpu, POssíveis controles na camada de VSW do Vmware, Firewall Horizontal, etc... Os valores acima foram tirados de um ambiente Haproxy em cima de Vmware Vsphere 7 com Intel Xeon Scalable 3rd gen (2Ghz), alpine linux tanto no docker host quanto no Haproxy container.

## Dimensionamento base

Com os testes, nota-se que a quantidade de vCPU em ambientes em que o HAproxy vai precisar operar muita conexão simultanea faz diferença.

Um ambiente minimo recomendado com alpine-linux como docker host para 1 container HAproxy, é de 2vCPU/1Gb de ram para resultados na casa de 18000 requests por segundo e uma banda estimada de 1,2Gbps e 100% de uso das 2vcpus. Um ambiente com 3vcpu traria cerca de 28000 requests por segundo também em 100% de vCPU. Com 4vcpu e acima, como mostram os resultados acima, não trazem ganho significativo para esse ambiente avaliado.

## Sysctl recomendado base

```
net.ipv4.tcp_rmem                       = 8192 174760 8388608
net.ipv4.tcp_wmem                       = 8192 174760 8388608
net.ipv4.tcp_tw_reuse                   = 1
net.ipv4.ip_local_port_range            = 1024 65023
net.ipv4.tcp_max_syn_backlog            = 60000
net.ipv4.tcp_fin_timeout                = 30
net.ipv4.tcp_synack_retries             = 3
net.ipv4.ip_nonlocal_bind               = 1
net.core.somaxconn                      = 60000
net.netfilter.nf_conntrack_max          = 2000000
net.netfilter.nf_conntrack_buckets      = 2000000
net.core.message_cost                   = 0
net.ipv4.ip_unprivileged_port_start     = 0

```

Dos parametros acima, usar com cuidado os que contem **nf_conntrack** principalmente em ambientes em que o HAproxy estara servindo acessos publicos via VPN ou internet, mais vulneráveis a DDOs ou SynFlood.