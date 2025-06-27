# Changelog

All notable changes to the UCCS LaTeX Templates project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2025-06-27

### Added

#### Templates & Document Generation
- **Professional LaTeX templates** for homework assignments and reports
- **UCCS branding integration** with official logo and DoD-blue color scheme
- **Fira Sans font family** integration with complete OpenType font set
- **XeLaTeX support** with proper font configuration and asset paths
- **Sample problem sets** demonstrating mathematical typesetting and equation formatting
- **Consistent document styling** with double-spacing, proper margins, and academic formatting

#### Automation & Scripting
- **Interactive document scaffolding** via `newdoc.sh` script
- **Makefile integration** with automated build processes and engine detection
- **Multi-engine support** (XeLaTeX, Tectonic, Latexmk) with automatic fallback
- **Configuration file system** (`.newdoc.conf`) for personal defaults and semester settings
- **Enhanced interactive prompts** with default values and smart field completion
- **Live compilation support** with watch mode for real-time document updates

#### Project Structure & Organization
- **Organized directory structure** with course/term-based file organization
- **Shared asset management** with centralized fonts, images, and resources
- **Automated directory creation** for new courses and terms
- **Proper asset path resolution** supporting multi-level directory structures

#### Documentation & User Experience
- **Comprehensive README.md** with quick start guides and detailed documentation
- **Interactive mode documentation** with example sessions and workflows
- **Configuration guides** for personal setup and semester management
- **Troubleshooting section** with common issues and solutions
- **UCCS-specific guides** for engineering, business, and graduate students
- **Adaptation instructions** for other universities

#### Build System & Development
- **Professional Makefile** with comprehensive targets and help system
- **Engine auto-detection** with preference ordering and fallback mechanisms
- **Clean and distclean targets** for build artifact management
- **PDF compilation workflows** with single-file and batch processing
- **Watch mode integration** for live document development

#### Legal & Compliance
- **Comprehensive licensing** with MIT License for original code
- **Third-party asset attribution** for Fira Sans fonts (OFL-1.1)
- **UCCS trademark compliance** with proper usage guidelines
- **Redistribution guidelines** and contact information for permissions

#### Security & Privacy
- **Personal information protection** with `.gitignore` rules for coursework
- **Configuration file exclusion** preventing accidental commits of personal data
- **Example file sanitization** using generic placeholders
- **Academic integrity support** keeping templates public while protecting submissions

### Technical Features

#### Font & Typography System
- **Complete Fira Sans family** (32 font variants) with proper XeLaTeX integration
- **Relative path resolution** supporting `../../../texmf/fonts/otf/` structure
- **Fallback font handling** with graceful degradation for missing weights
- **Professional typography** with consistent heading hierarchy and spacing

#### Graphics & Asset Management
- **Centralized image repository** in `texmf/images/` with shared logo assets
- **Course-specific figure support** with `classes/COURSE/TERM/figures/` structure
- **Automatic graphics path configuration** with proper LaTeX `\graphicspath` setup
- **UCCS logo integration** with proper sizing and placement

#### Template System
- **Homework template** with problem environments, mathematical typesetting, and compact layout
- **Report template** with title page, structured sections, and academic formatting
- **Placeholder substitution system** with safe string replacement and escaping
- **Course information integration** with automatic header and title generation

#### Build & Compilation
- **Cross-platform compatibility** with macOS, Linux, and Windows support
- **Engine detection logic** with automatic tool discovery and configuration
- **Error handling and validation** with meaningful error messages
- **Batch processing support** for multiple document compilation

#### Interactive Workflows
- **Smart default prompting** with configuration file integration
- **Visual feedback** with emojis and clear progress indicators
- **Field validation** with type checking and format verification
- **Semester management** with term-specific directory organization

### Infrastructure

#### Version Control & Distribution
- **Git repository structure** with proper `.gitignore` and branch management
- **GitHub integration** with public repository and community features
- **Release management** with semantic versioning and changelog maintenance
- **Issue tracking** and discussion forum setup for community support

#### Continuous Integration
- **Tectonic CI/CD configuration** for automated document building
- **Docker support** with containerized build environments
- **Multi-platform testing** ensuring compatibility across environments

#### Community & Discoverability
- **SEO-optimized repository** with descriptive naming and comprehensive topics
- **University-specific documentation** highlighting UCCS integration
- **Adaptation guides** for other institutions and customization needs
- **Professional documentation** following open-source best practices

### Dependencies & Requirements
- **XeLaTeX or Tectonic** for document compilation
- **Make** for build automation and workflow management
- **Bash** for script execution and interactive features
- **Git** for version control and repository management

---

## Development Notes

### Semantic Versioning
This project follows [Semantic Versioning](https://semver.org/):
- **MAJOR** version for incompatible API changes
- **MINOR** version for backwards-compatible functionality additions  
- **PATCH** version for backwards-compatible bug fixes

### Release Process
1. Update CHANGELOG.md with new features and changes
2. Bump version in relevant files (README badges, documentation)
3. Create git tag with version number
4. Push tag to trigger release process
5. Create GitHub release with changelog notes

### Contributing
See [README.md](README.md) for contribution guidelines and development setup.

[Unreleased]: https://github.com/ddunnock/uccs-latex-templates/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/ddunnock/uccs-latex-templates/releases/tag/v1.0.0
