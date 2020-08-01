FROM node:13.6-buster-slim
RUN apt update && apt install -y xvfb pulseaudio ffmpeg mpv

ENV DISPLAY :0

COPY entrypoint entrypoint

RUN chmod +x entrypoint/entrypoint.sh

ENTRYPOINT ["entrypoint/entrypoint.sh"]
