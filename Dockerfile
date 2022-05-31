FROM debian:9 as build

RUN apt update && apt install -y wget gcc make libpcre3-dev zlib1g-dev
RUN wget https://nginx.org/download/nginx-1.20.2.tar.gz && tar xvfz nginx-1.20.2.tar.gz && cd nginx-1.20.2 && ./configure && make && make install
RUN cd /usr/local \
	&& wget https://github.com/openresty/lua-resty-lrucache/archive/v0.09.tar.gz \
	&& wget https://github.com/openresty/lua-resty-core/archive/v0.1.17.tar.gz \
	
	&& tar -C $(pwd) -xzvf v0.1.17.tar.gz \
	&& cd lua-resty-core-0.1.17 \
	&& make install \
	&& cd .. \
	
	&& tar -C $(pwd) -xzvf v0.09.tar.gz \
	&& cd lua-resty-lrucache-0.09 \
	&& make install

FROM debian:latest

WORKDIR /usr/local/nginx/sbin

COPY --from=build /usr/local/nginx/sbin/nginx .

RUN mkdir /usr/local/nginx/lib
COPY --from=build /usr/local/lib/ /lib

RUN mkdir ../logs ../modules ../conf && touch ../logs/error.log && touch ../logs/access.log && touch ../logs/nginx.pid && chmod +x nginx
COPY --from=build /usr/local/nginx/conf/mime.types /usr/local/nginx/conf/

CMD ["./nginx", "-g", "daemon off;"]
