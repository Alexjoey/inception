FROM debian:bookworm

RUN apt-get update -y && apt-get install -y \
	nginx \
	openssl \
	bash

COPY ./tools/script.sh /

RUN chmod +x /script.sh

CMD ["/script.sh"]
