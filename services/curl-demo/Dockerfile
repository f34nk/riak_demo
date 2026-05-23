FROM alpine:3.20

RUN apk add --no-cache curl bash

WORKDIR /app
COPY demo.sh .
RUN chmod +x demo.sh

CMD ["bash", "demo.sh"]
