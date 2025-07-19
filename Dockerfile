FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /workspace

# Install base dependencies
RUN apt-get update && apt-get install -y \
    curl wget git sudo nano unzip gnupg2 ca-certificates \
    build-essential python3 python3-pip python3-venv \
    software-properties-common \
    postgresql postgresql-contrib \
    && apt-get clean

# Install Node.js 18 (LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | bash \
    && mkdir -p /workspace/.ollama \
    && ln -s /workspace/.ollama /root/.ollama

# Install Flowise globally (Node-based)
RUN npm install -g flowise

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN mkdir -p /workspace/.config/code-server \
    && mkdir -p /root/.config \
    && ln -s /workspace/.config/code-server /root/.config/code-server

# Install Chroma with server support
RUN pip install chromadb[server]

# Then run it like this:
# RUN chromadb --host 0.0.0.0 --port 8000 --path /workspace/chroma
RUN python3 -m chromadb.cli.cli --help

# Configure PostgreSQL to use /workspace/postgres-data
RUN service postgresql start && \
    sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';" && \
    service postgresql stop && \
    mkdir -p /workspace/postgres-data && \
    chown -R postgres:postgres /workspace/postgres-data && \
    sed -i 's|/var/lib/postgresql/[^ ]*|/workspace/postgres-data|' /etc/postgresql/*/main/postgresql.conf

# Expose all ports
EXPOSE 7860
EXPOSE 3000
EXPOSE 8080
EXPOSE 5432

# Add start script
# COPY ../start.sh start.sh
# RUN chmod +x start.sh

CMD ["./start.sh"]
