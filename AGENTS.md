# Project Purpose

This base app will be used for our discovery cycle to test how AI tools translate Infrastructure as Code (IaC) between AWS, Azure, and GCP—using a simple full-stack app—to simplify migrations. The goal is to assess tool effectiveness, with deliverables including findings, guidance, and a practical playbook for engineers and architects.

This base app is AWS-native and designed to be translated to other cloud platforms using AI tools.

For this specific instance we will be using the AWS terraform scripts in the /infrastructure folder as a starting point for migrating the AWS based infrastructure to Azure infrastructure. 

---

# Interaction Norms

We're colleagues working together. Neither of us is afraid to admit when we don't know something or are in over our head.

When we think we're right, it's **good to push back, but we should cite evidence** (e.g., documentation, security best practices, or performance analysis).

---

# Writing Code

- We prefer **simple, clean, maintainable solutions** over clever or complex ones, even if the latter are more concise or performant. Readability and maintainability are primary concerns.

- **Doing it right is better than doing it fast.** You are not in a rush. NEVER skip steps or take shortcuts.

- **Stay focused.** Fix only what relates to your current task. Notice something else that needs work? Document it separately (e.g., in a new issue or comment) rather than fixing it now.

- **Preserve comments.** They're documentation, not clutter.

- Write **evergreen code**. Describe what code does, not when it was written (i.e., avoid 'newFunction' or 'temp_fix').

- Create a new branch and work with pull requests when implementing new features.

---

# Getting Help

- If you're confused or having trouble with something, you are **strongly encouraged to stop and ask for help**. Especially if it's something your human might be better at (e.g., design discussions, high-level architecture decisions).

## Decision-Making Framework

### 🟢 Proceed Immediately (Low Risk, Local Impact)

- Fix tests, linting errors, or type errors.
- Implement single functions with clear specs.
- Correct typos, formatting, or documentation.
- Refactor *within* a single file to improve clarity.
- Add missing imports or dependencies.

### 🟡 Propose First (Medium Risk, Multi-File Impact)

- Changes spanning multiple files.
- New features or significant functionality.
- API or interface changes (e.g., adding a new endpoint parameter).
- Introducing a new, minor library or tool.

### 🔴 Always Explicitly Ask a Human First! (High Risk, Core Impact)

- Rewriting working code from scratch.
- **Changing core business logic** or removing existing functionality.
- Security modifications or changes to authentication/authorization.
- Introducing a new major technology (e.g., a new database type).

---

# Designing Solutions

## 1. Build for Composition

- Each service delivers **one focused capability**.

- When proposing major new functionality, ask: "**Should this be a separate service?**" Be pragmatic, but default to yes if the capability is clearly independently useful.

## 2. API-First Design

- Services expose **documented REST APIs**.

- Start new feature development by defining or updating an **API contract in an `openapi.yaml` file** using the OpenAPI 3.x standard.

- Internal services communicate through APIs, not direct database access or shared code. This ensures each service can be replaced or reused independently.

## 3. Design for Deployment

- Package services in **containers** with clear deployment documentation.

- Use `docker-compose.yml` to define and run the complete application stack and manage services, networking, and dependencies for **local development and testing**.

- Use **multi-stage builds** and **slim images** (like `node:18-alpine`, `python:3.11-slim`, etc.) to create small, secure containers.

- Create a **non-root user** in your Dockerfile and run the container process as that user.

- **Externalize all configuration!** Configure through environment variables, feature flags, and mounted config files.

- Load all secrets from Docker secret files (e.g., `/run/secrets/`) or environment variables—**NEVER hard-code secrets** in the image or commit them to source control.

## 4. Write for Handoff

- Write code assuming the **partner agency will maintain it without us**.

- Include clear **README files**, architecture decision records (ADRs), and **inline documentation** explaining the "why" behind any non-obvious choices.

---

# Technology Stack

- **Backend:** **FastAPI** (Python 3.11+), **SQLAlchemy 2.x** (async with `aiosqlite` for SQLite).
- **Frontend:** **React 18+** with **TypeScript**.
- **Package management:** **uv** (single source of truth in `pyproject.toml`).
- **Design system:** **USWDS** via `@trussworks/react-uswds`.
- **Containerization:** **Docker** with `docker-compose` for local development.

## Dependency Management (Python with uv)

- Manage all Python deps with **uv**; commit `pyproject.toml` and `uv.lock`.
- Target Python `>= 3.11`; set `requires-python = ">=3.11"` in `pyproject.toml`.

Examples (fish shell):

```sh
# Initialize or sync environment
uv venv .venv
uv sync

# Add/remove packages
uv add fastapi "uvicorn[standard]" pydantic-settings sqlalchemy
uv remove sqlalchemy

# Run tools through uv to ensure the right environment
uv run pytest -q
uv run uvicorn app.main:app --reload
