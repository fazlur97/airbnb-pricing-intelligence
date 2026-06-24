FROM python:3.11-slim

WORKDIR /project

# Install dbt + DuckDB
RUN pip install dbt-duckdb duckdb pandas

RUN apt-get update && apt-get install -y git
# Copy project files
COPY . .

# Default command
CMD ["bash"]