# Contributing to StreamPlatform

Thank you for your interest in contributing to StreamPlatform! This document provides guidelines and instructions for contributing to the project.

## Code of Conduct

Please be respectful and professional in all interactions. We are committed to providing a welcoming and inclusive environment for all contributors.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** to your local machine
3. **Create a feature branch** from `develop`
4. **Set up the development environment** (see SETUP_GUIDE.md)
5. **Make your changes** and commit them
6. **Push to your fork** and submit a pull request

## Development Workflow

### Branch Naming
- Feature: `feature/description`
- Bugfix: `bugfix/description`
- Hotfix: `hotfix/description`
- Documentation: `docs/description`

### Commit Messages
Follow conventional commits format:
```
<type>(<scope>): <subject>

<body>

<footer>
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Tests
- `chore`: Build/tooling changes
- `ci`: CI/CD changes

### Code Style

#### JavaScript/TypeScript
- Use ESLint configuration provided
- Format with Prettier
- Use TypeScript for type safety
- 2-space indentation

#### Python
- Follow PEP 8
- Use Black for formatting
- Use mypy for type checking

### Testing

Before submitting a pull request:

1. **Run tests**: `npm test`
2. **Run linter**: `npm run lint`
3. **Check types**: TypeScript compilation should succeed
4. **Format code**: `npm run format`

### Pull Request Process

1. **Update documentation** if needed
2. **Add tests** for new features
3. **Ensure CI passes** (all checks must pass)
4. **Provide a clear description** of your changes
5. **Link related issues** using GitHub keywords
6. **Request review** from maintainers

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Related Issues
Closes #(issue number)

## Testing
Describe testing done

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] All tests passing
```

## Project Structure

See [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) for detailed information about the repository structure.

## Development Commands

```bash
# Start all services
make up

# Stop all services
make down

# Run tests
make test

# Run linter
make lint

# Format code
make fmt

# View all available commands
make help
```

## Reporting Issues

When reporting bugs, please include:

1. **Description** of the issue
2. **Steps to reproduce**
3. **Expected behavior**
4. **Actual behavior**
5. **Environment** (OS, Node version, etc.)
6. **Screenshots** (if applicable)

## Questions?

For questions or discussions:
- Open a GitHub Discussion
- Check existing issues and PRs
- Review the documentation

## License

By contributing to StreamPlatform, you agree that your contributions will be licensed under its MIT License.
