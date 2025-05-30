FROM debian:bookworm

RUN apt-get update -y && apt-get install mariadb-server -y

COPY ./tools/script.sh /

RUN chmod +x script.sh

CMD ["/script.sh"]
