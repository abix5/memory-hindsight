# Claude Code Plugin Development Guide

> Полное руководство по разработке плагинов для Claude Code

## О документе

Этот документ - комплексное руководство по созданию, тестированию и публикации плагинов для Claude Code. Он охватывает все аспекты разработки: от структуры плагина до лучших практик и валидации.

---

## 📋 Содержание

1. [Введение в плагины](#введение-в-плагины)
2. [Marketplace и управление](#marketplace-и-управление)
3. [Архитектура плагина](#архитектура-плагина)
4. [Компоненты плагина](#компоненты-плагина)
5. [Конвенции и Best Practices](#конвенции-и-best-practices)
6. [Технические детали](#технические-детали)
7. [Разработка и тестирование](#разработка-и-тестирование)
8. [Публикация](#публикация)
9. [Уроки разработки](#уроки-разработки)
10. [Validation Checklist](#validation-checklist)

---

## 🚀 Введение в плагины

### Что такое плагин?

Плагин Claude Code - это модуль, расширяющий функциональность Claude Code новыми возможностями. Плагины могут включать:

- **Slash Commands** - пользовательские команды, вызываемые через `/plugin-name:command`
- **Agents** - автономные агенты для выполнения сложных задач
- **Skills** - специализированные знания для контекстуальной помощи
- **Hooks** - обработчики событий для автоматизации
- **MCP Integration** - подключение внешних сервисов через Model Context Protocol

### Типы плагинов

| Тип | Описание | Примеры |
|-----|----------|---------|
| **Integration** | Подключение внешних сервисов | Database integrations, API clients |
| **Workflow** | Автоматизация рабочих процессов | Git workflows, CI/CD |
| **Analysis** | Анализ кода и метрик | Code quality, security scanners |
| **Toolkit** | Набор утилит | File manipulation, text processing |
| **Memory** | Хранение и извлечение данных | Project memory, decision tracking |

---

## 🏪 Marketplace и управление

### Структура Marketplace

Marketplace - это репозиторий, содержащий несколько плагинов:

```
my-marketplace/
├── .claude-plugin/
│   └── marketplace.json         # Манифест marketplace
└── plugins/
    ├── plugin-one/              # Первый плагин
    │   └── .claude-plugin/
    │       └── plugin.json
    └── plugin-two/              # Второй плагин
        └── .claude-plugin/
            └── plugin.json
```

**marketplace.json формат:**
```json
{
  "name": "my-marketplace",
  "version": "1.0.0",
  "description": "Описание marketplace",
  "plugins": ["plugin-one", "plugin-two"]
}
```

### Команды управления плагинами

```bash
# Добавить marketplace из GitHub
/plugin marketplace add username/marketplace-repo

# Добавить marketplace из локальной директории
/plugin marketplace add /path/to/marketplace

# Установить плагин из marketplace
/plugin install plugin-name@marketplace-name

# Установить из официального marketplace
/plugin install plugin-name@claude-code-marketplace

# Список установленных плагинов
/plugin list

# Локальная разработка (без установки)
cc --plugin-dir /path/to/plugin-name
```

**Важно:**
- Для локальной разработки используйте `cc --plugin-dir` вместо `/plugin install`
- Marketplace добавляется один раз, затем можно устанавливать любые плагины из него
- Формат установки: `plugin-name@marketplace-name` или `plugin-name@username/repo`

---

## 🏗️ Архитектура плагина

### Структура плагина

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json              # Манифест плагина (обязательный)
├── commands/                    # Slash команды (опционально)
│   └── my-command.md
├── agents/                      # Автономные агенты (опционально)
│   └── my-agent.md
├── skills/                      # Навыки (опционально)
│   └── my-skill/
│       ├── SKILL.md
│       ├── references/
│       ├── examples/
│       └── scripts/
├── hooks/                       # Обработчики событий (опционально)
│   └── hooks.json
├── scripts/                     # Вспомогательные скрипты (опционально)
│   └── utility.sh
├── .mcp.json                    # MCP конфигурация (опционально)
├── README.md                    # Документация (обязательный)
└── .gitignore
```

### Plugin Manifest (plugin.json)

**Назначение:** Центральный файл метаданных плагина

**Расположение:** `plugin-name/.claude-plugin/plugin.json`

**Обязательные поля:**
```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Краткое описание плагина"
}
```

**Опциональные поля:**
```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Краткое описание",
  "author": {
    "name": "Author Name",
    "email": "author@example.com"
  },
  "license": "MIT",
  "homepage": "https://github.com/user/plugin",
  "repository": "https://github.com/user/plugin.git"
}
```

**Правила:**
- ✅ Используйте kebab-case для `name`
- ✅ Semantic Versioning для `version` (major.minor.patch)
- ✅ Описание должно быть кратким и понятным
- ❌ НЕ включайте секреты или API ключи

---

## 🧩 Компоненты плагина

### Slash Commands

**Назначение:** Пользовательские команды, вызываемые через `/plugin-name:command-name`

**Ключевые особенности:**
- Выполняют bash-команды через синтаксис `!`команда``
- Получают результаты до выполнения промпта
- Используют `${CLAUDE_PLUGIN_ROOT}` для портативности
- Содержат промпт-инструкции для Claude

#### Базовая структура команды

```markdown
---
description: Brief description
argument-hint: [arg1] [arg2]
allowed-tools: Read, Bash(git:*)
model: sonnet
disable-model-invocation: false
---

Command prompt content with:
- Arguments: $1, $2, or $ARGUMENTS
- Files: @path/to/file
- Bash: !`command here`
```

#### Поля frontmatter

| Поле | Обязательное | Описание |
|------|--------------|----------|
| `description` | ✅ | Краткое описание для `/help` |
| `allowed-tools` | ❌ | Список разрешённых инструментов |
| `argument-hint` | ❌ | Подсказка аргументов в квадратных скобках |
| `model` | ❌ | Модель: `sonnet`, `opus`, `haiku`, `inherit` |
| `disable-model-invocation` | ❌ | Если `true`, выполняется без вызова модели |

#### Allowed Tools спецификация

```yaml
# Все инструменты Bash
allowed-tools: Bash

# Только git команды
allowed-tools: Bash(git:*)

# Несколько git команд
allowed-tools: Bash(git:commit, git:push)

# Несколько инструментов
allowed-tools: ["Read", "Write", "Bash(git:*)"]

# Все инструменты (по умолчанию, если не указано)
# (любой инструмент может быть использован)
```

**Спецификация команд:**
- `Bash(*)` - все bash команды
- `Bash(git:*)` - только git команды (git:commit, git:push, и т.д.)
- `Bash(git:commit, git:push)` - только конкретные команды
- `Read` - чтение файлов
- `Write` - запись файлов
- `Edit` - редактирование файлов
- `Grep` - поиск в файлах
- `Glob` - поиск файлов по паттерну

#### Специальные переменные

**Аргументы:**
```bash
$1          # Первый аргумент
$2          # Второй аргумент
$3, $4...   # Третий, четвертый, и т.д.
$ARGUMENTS  # Все аргументы вместе
```

**Файлы:**
```markdown
@path/to/file          # Включить содержимое файла
@${CLAUDE_PLUGIN_ROOT}/templates/default.md  # Файл из плагина
```

**Bash execution:**
```markdown
!`command`             # Выполнить и вставить вывод
!`bash script.sh $1`   # С аргументами
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/run.sh $ARGUMENTS`
```

**Environment:**
```bash
${CLAUDE_PLUGIN_ROOT}  # Корневая директория плагина
${HOME}                # Home директория пользователя
${PWD}                 # Текущая рабочая директория
```

#### Примеры команд

**Простая команда с bash execution:**

```markdown
---
description: Show current Git status
allowed-tools: Bash(git:*)
---

Current git status:

!`git status`

Recent commits:

!`git log --oneline -5`
```

**Команда с аргументами:**

```markdown
---
description: Deploy application to environment
argument-hint: [app-name] [environment] [version]
allowed-tools: Bash(kubectl:*), Read
---

Deploying $1 to $2 environment using version $3

Pre-deployment checks:
- Verify $2 configuration: !`kubectl get config $2 -o yaml`
- Check cluster status: !`kubectl cluster-info`
- Validate version $3 exists

Proceed with deployment following deployment runbook.
```

**Команда с file reference:**

```markdown
---
description: Generate report from template
argument-hint: [output-file]
allowed-tools: Read, Write, Bash
---

Using template:

@${CLAUDE_PLUGIN_ROOT}/templates/report-template.md

Generate report and save to $1.

Collect data:
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/collect-data.sh`

Apply template and write to $1.
```

#### Написание команд FOR Claude, не FOR пользователей

**❌ ПЛОХО - написано для пользователя:**

```markdown
---
description: This command will review your code
---

This command reviews your code for bugs and style issues.
It will check each file and provide feedback.
```

**✅ ХОРОШО - написано для Claude:**

```markdown
---
description: Review code for bugs and style issues
allowed-tools: Read, Grep
---

Review this code for:
- Security vulnerabilities
- Logic errors
- Style violations
- Performance issues

For each issue found, provide:
- File and line number
- Severity level (Critical/Important/Suggestion)
- Specific fix recommendation
- Code example of the fix
```

**Ключевое различие:**
- ❌ "This command will..." - описание того, что делает команда (для пользователя)
- ✅ "Review this code for..." - инструкции что делать (для Claude)

#### Организация команд

**Project commands** (в `.claude/commands/`):
```
.claude/commands/
├── review.md           # /review
├── test.md             # /test
└── deploy.md           # /deploy
```

**Plugin commands** (в `plugins/my-plugin/commands/`):
```
plugins/my-plugin/commands/
├── init.md             # /my-plugin:init
├── config.md           # /my-plugin:config
└── deploy.md           # /my-plugin:deploy
```

**Namespacing:**
- Project commands: `/command-name`
- Plugin commands: `/plugin-name:command-name`
- Полное имя плагина для ясности

#### Продвинутые паттерны

**Multi-script workflow:**

```markdown
---
description: Complete build and test workflow
allowed-tools: Bash(*)
---

Build: !`bash ${CLAUDE_PLUGIN_ROOT}/scripts/build.sh`
Validate: !`bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh`
Test: !`bash ${CLAUDE_PLUGIN_ROOT}/scripts/test.sh`

Review all outputs and report:
1. Build status
2. Validation results
3. Test results
4. Recommended next steps
```

**Command chaining:**

```markdown
---
description: Prepare for code review
---

# Prepare Code Review

Running preparation sequence:

1. Format code: /format-code
2. Run linter: /lint-code
3. Run tests: /test-all
4. Generate coverage: /coverage-report
5. Create review summary: /review-summary

This is a meta-command. After completing each step above,
compile results and prepare comprehensive review materials.

Starting sequence...
```

**Interactive commands with AskUserQuestion:**

```markdown
---
description: Interactive project setup
allowed-tools: AskUserQuestion, Write, Bash
---

# Project Setup

## Stage 1: Basic Configuration

Use AskUserQuestion to gather:

**Question 1:** Which programming language?
- Python (Flexible, great for scripts)
- TypeScript (Type-safe, scalable)
- Go (Fast, efficient)
- Rust (Performance, memory safety)

**Question 2:** Which test framework?
[Adapt based on language selection]

## Stage 2: Advanced Options (Conditional)

If user selected "Advanced" in Stage 1:
Ask about load balancing, caching, security

If "Simple":
Use sensible defaults

## Stage 3: Confirmation

Show summary of all selections.

Use AskUserQuestion for final confirmation:
- Yes (Proceed with setup)
- No (Start over)
- Modify (Adjust specific settings)
```

#### Best Practices для команд

**✅ Do:**
- Пишите инструкции FOR Claude, not FOR users
- Используйте `${CLAUDE_PLUGIN_ROOT}` для portable paths
- Ограничивайте `allowed-tools` для безопасности
- Предоставляйте清晰的 следующий шаги
- Используйте bash execution для получения данных
- Валидируйте входные аргументы
- Показывайте progress для длительных операций

**❌ Don't:**
- Не включайте `name` в frontmatter
- Не пишите описания "This command will..."
- Не используйте hardcoded paths
- Не разрешайте все инструменты без необходимости
- Не оставляйте пользователя без clear next steps
- Не злоупотребляйте bash execution (может быть медленным)

#### Когда использовать Commands vs Agents vs Skills

| Компонент | Когда использовать | Пример |
|-----------|-------------------|---------|
| **Command** | Пользователь явно вызывает действие | `/deploy`, `/test`, `/review` |
| **Agent** | Автономная многошаговая задача | Анализ кода, генерация документации |
| **Skill** | Справочная информация | Best practices, API reference |

**Пример:**

```markdown
# ❌ ПЛОХО - Command для сложной задачи
---
description: Analyze entire codebase and suggest improvements
---

# Это должен быть Agent!

# ✅ ХОРОШО - Command для простого действия
---
description: Run tests and show results
---

!`npm test`

Analyze results and provide summary.
```

#### Performance и оптимизация

**Bash execution порядок:**
```markdown
# Bash выполняется ДО того как Claude видит промпт

---
description: Get git status
---

Current branch: !`git branch --show-current`
Status: !`git status --short`

# Claude видит уже выполненные команды и их вывод
```

**Кэширование результатов:**
```markdown
# Для дорогостоящих операций
---
description: Analyze code complexity
allowed-tools: Bash, Read
---

Check if analysis exists:
!`test -f .claude/complexity-cache.json && echo "cached" || echo "not-cached"`

If cached: @.claude/complexity-cache.json
If not: Run analysis and cache results
```

**Минимизация bash вызовов:**
```markdown
# ❌ ПЛОХО - множественные вызовы
!`git status`
!`git log --oneline -5`
!`git diff --stat`

# ✅ ХОРОШО - один вызов
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/git-info.sh`
```

#### Troubleshooting

**Команда не появляется в `/help`:**
- Проверьте что файл в правильной директории (`commands/`)
- Убедитесь что расширение `.md`
- Проверьте что frontmatter валиден
- Перезапустите Claude Code

**Bash команды не выполняются:**
- Проверьте `allowed-tools: ["Bash"]`
- Убедитесь что используете `!`command`` синтаксис
- Проверьте права на исполнение скриптов: `chmod +x`

**Аргументы не передаются:**
- Используйте `$1`, `$2` для позиционных аргументов
- Используйте `$ARGUMENTS` для всех аргументов
- Проверьте `argument-hint` в frontmatter

**Важно:**
- ❌ **НЕ включать** поле `name` в frontmatter - имя берётся из названия файла
- ✅ Команды должны **инструктировать Claude**, а не пользователя
- ✅ Bash execution выполняется **до** того как Claude видит промпт
- ✅ Всегда использовать `${CLAUDE_PLUGIN_ROOT}` для путей к скриптам
- ✅ Используйте третий лицо в описаниях для `/help`

### Agents

**Назначение:** Автономные подпроцессы для сложных многошаговых задач

**Ключевые особенности:**
- Autonomous operation (работают самостоятельно)
- Специализация на конкретной задаче
- Могут вызываться автоматически Claude на основе контекста

**Структура агента:**
```markdown
---
name: agent-name
description: Use this agent when... Examples:
<example>
Context: [Ситуация]
user: "[Запрос пользователя]"
assistant: "[Ответ ассистента]"
<commentary>
[Почему агент должен быть вызван]
</commentary>
</example>
model: inherit
color: blue
tools: ["Read", "Bash", "Grep"]
---

# Agent Name

You are [описание роли агента]...

## Your Core Responsibilities:
1. [Ответственность 1]
2. [Ответственность 2]

## Process:
[Пошаговый процесс работы]

## Output Format:
[Что возвращать пользователю]
```

**Поля frontmatter:**

| Поле | Обязательное | Описание |
|------|--------------|----------|
| `name` | ✅ | Идентификатор агента (kebab-case, 3-50 символов) |
| `description` | ✅ | Когда использовать, с примерами |
| `model` | ✅ | Модель: `inherit`, `sonnet`, `opus`, `haiku` |
| `color` | ✅ | Цвет для UI: `blue`, `cyan`, `green`, `yellow`, `magenta`, `red` |
| `tools` | ❌ | Ограничение набора инструментов |

**Формат description с примерами:**
```yaml
---
description: Use this agent when X happens. Examples:

<example>
Context: User needs to validate something
user: "Can you check if this is valid?"
assistant: "I'll use the validator agent to check this."
<commentary>
Validator request triggers validation agent
</commentary>
</example>

<example>
Context: Proactive validation after changes
user: "I've updated the configuration"
assistant: "Let me validate those changes using the validator agent."
<commentary>
Configuration changes trigger proactive validation
</commentary>
</example>
---
```

**Критически важно:**
- ✅ **Description должен содержать `<example>` блоки** - это ОФИЦИАЛЬНЫЙ формат
- ✅ Каждый пример: Context, user, assistant, commentary
- ✅ Показывать и proactive (автоматические), и reactive (явные) сценарии
- ✅ 2-4 конкретных примера
- ✅ "Use this agent when..." для триггеров
- ✅ Model обычно `inherit` или `sonnet`
- ✅ Tools - минимум необходимых

### Skills

**Назначение:** Знания и рекомендации, которые Claude применяет автоматически

**Отличие от других компонентов:**
- Commands - пользователь вызывает явно
- Agents - Claude запускает для выполнения задач
- Skills - Claude использует как справочную информацию

**Структура skill:**
```markdown
---
name: skill-name
description: This skill should be used when the user asks to "specific phrase 1", "specific phrase 2". Be concrete and specific.
model: sonnet
version: 0.1.0
---

# Skill Content

Подробные инструкции, best practices, примеры...
```

**Поля frontmatter:**

| Поле | Обязательное | Описание |
|------|--------------|----------|
| `name` | ✅ | Идентификатор skill (kebab-case) |
| `description` | ✅ | Конкретные фразы для триггера (третье лицо) |
| `model` | ✅ | Модель: `sonnet`, `haiku` |
| `version` | ❌ | Версия skill (semantic versioning) |

**Формат description:**
```yaml
---
# ❌ ПЛОХО - слишком общий
description: Use this skill when working with hooks

# ✅ ХОРОШО - конкретные фразы
description: This skill should be used when the user asks to "create a hook", "add a PreToolUse hook", "validate tool use", or mentions hook events (PreToolUse, PostToolUse, Stop).
---
```

**Progressive Disclosure:**

```
skill-name/
├── SKILL.md                 # 1,500-2,000 слов - основное
└── references/              # Подробная справка
    ├── patterns.md          # Паттерны
    ├── advanced.md          # Продвинутые техники
    └── examples.md          # Рабочие примеры
```

**Auto-Discovery:**
- Сканирование `skills/` для подпапок с `SKILL.md`
- Загрузка метаданных немедленно
- Загрузка SKILL.md при триггере
- Загрузка references по требованию

**Важно:**
- ✅ Third-person writing style
- ✅ Imperative form в body
- ✅ Конкретные trigger phrases
- ✅ Progressive disclosure pattern

### Hooks

**Назначение:** Автоматическая реакция на события в Claude Code

#### Hook события

| Событие | Когда вызывается | Применение |
|---------|-----------------|------------|
| `PreToolUse` | Перед использованием инструмента | Валидация, security, approve/deny |
| `PostToolUse` | После использования инструмента | Логирование, реакции |
| `Stop` | Перед завершением сессии | Cleanup, проверка задач |
| `SubagentStop` | Когда завершается подагент | Обработка результатов |
| `SessionStart` | Начало сессии | Загрузка контекста |
| `SessionEnd` | Конец сессии | Финализация |
| `UserPromptSubmit` | Отправка промпта пользователем | Модификация запроса |
| `PreCompact` | Перед сжатием истории | Сохранение важного |
| `Notification` | Системное уведомление | Обработка уведомлений |

#### Hook Input Format

Все хуки получают input через `stdin` как JSON объект:

**Общие поля (для всех хуков):**
```json
{
  "session_id": "uuid",
  "transcript_path": "/path/to/transcript",
  "cwd": "/current/working/directory",
  "permission_mode": "ask|allow",
  "hook_event_name": "PreToolUse|PostToolUse|..."
}
```

**Event-specific поля:**

**PreToolUse:**
```json
{
  "tool_name": "Write|Edit|Bash|...",
  "tool_input": {
    // параметры инструмента
  }
}
```

**PostToolUse:**
```json
{
  "tool_name": "...",
  "tool_input": {...},
  "tool_result": {
    // результат выполнения
  }
}
```

**UserPromptSubmit:**
```json
{
  "user_prompt": "текст запроса пользователя"
}
```

**Stop:**
```json
{
  "reason": "причина остановки"
}
```

**SubagentStop:**
```json
{
  "agent_name": "имя агента",
  "result": {
    // результат работы агента
  }
}
```

**Доступ к input в prompts:**
- `$TOOL_NAME` - имя инструмента
- `$TOOL_INPUT` - параметры инструмента (JSON)
- `$TOOL_RESULT` - результат (для PostToolUse)
- `$USER_PROMPT` - запрос пользователя
- `$SESSION_ID` - ID сессии
- `$CWD` - текущая директория

#### Структура hooks.json

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Validate file write safety. Return 'approve' or 'deny'."
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Check unsaved work and ask to save if needed."
          }
        ]
      }
    ]
  }
}
```

**Критически важно:**
- ✅ Корневой ключ ДОЛЖЕН быть `"hooks"`
- ✅ Используйте `{"hooks": {...}}` структуру
- ❌ НЕ используйте `{"Stop": [...]}` напрямую

#### Типы хуков

**1. Prompt-based hooks** (рекомендуется):

```json
{
  "type": "prompt",
  "prompt": "Инструкция для LLM"
}
```

**Когда использовать:**
- Сложная логика требующая понимания контекста
- Принятие решений на основе анализа
- Валидация которая требует интерпретации

**Пример:**
```json
{
  "PreToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "prompt",
          "prompt": "File path: $TOOL_INPUT.file_path. Verify: 1) Not in /etc or system directories 2) Not .env or credentials 3) Path doesn't contain '..' traversal. Return 'approve' or 'deny'."
        }
      ]
    }
  ]
}
```

**2. Command-based hooks:**

```json
{
  "type": "command",
  "command": "bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh"
}
```

**Когда использовать:**
- Детерминированная валидация
- Быстрые проверки без сложной логики
- Интеграция с внешними инструментами

**Пример скрипта:**
```bash
#!/bin/bash
set -euo pipefail

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name')

# Валидация
if [[ ! "$tool_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
  echo '{"decision": "deny", "reason": "Invalid tool name"}' >&2
  exit 2
fi

exit 0
```

**Exit codes для command hooks:**
- `0` - Allow operation
- `1` - Show stderr to user, continue
- `2` - Block operation, show stderr to Claude

#### Matcher Patterns

**Базовые patterns:**
```json
"*"              // Все события
"Write"          // Конкретный инструмент
"Write|Edit"     // Несколько инструментов (regex)
"Bash(git:*)"    // Bash команды с префиксом git
```

**Advanced patterns:**
```json
"Write.*\.(js|ts)"  // Write инструментов с определенными расширениями
"Bash(rm|mv|cp)"   // Конкретные bash команды
"(Read|Write).*\.env"  // Read или Write для .env файлов
```

**Правила:**
- Используйте regex для сложных matchers
- Тестируйте patterns перед деплоем
- Используйте специфичные patterns вместо "*" где возможно

#### Hook Output Format

**PreToolUse output:**
```json
{
  "hookSpecificOutput": {
    "permissionDecision": "allow|deny|ask",
    "updatedInput": {
      "field": "modified_value"
    }
  },
  "systemMessage": "✅ Status message"
}
```

**Stop hook output:**
```json
{
  "decision": "approve|block",
  "reason": "Explanation",
  "systemMessage": "✅ All checks passed"
}
```

**Стандартный hook output:**
```json
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "✅ Validation completed"
}
```

**Output на stdout для command hooks:**
```bash
# JSON output на stdout
echo '{"continue": true, "systemMessage": "✅ OK"}'

# Или просто status message
echo "✅ Validation passed"
```

#### Hook Execution Order

**Порядок выполнения:**
1. Hooks выполняются в порядке определения в массиве
2. Если один hook блокирует, следующие не выполняются
3. Hooks одного события не зависят друг от друга

**Hook priority:**
- Hooks из плагинов выполняются в алфавитном порядке имени плагина
- Project hooks (`.claude/hooks.json`) выполняются после plugin hooks

**Chaining hooks:**
```json
{
  "PreToolUse": [
    {
      "matcher": "Write",
      "hooks": [
        {
          "type": "command",
          "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/step1-validate.sh"
        },
        {
          "type": "command",
          "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/step2-check.sh"
        }
      ]
    }
  ]
}
```

#### Advanced Hook Patterns

**Security validation pattern:**
```json
{
  "PreToolUse": [
    {
      "matcher": "Bash",
      "hooks": [
        {
          "type": "prompt",
          "prompt": "Validate bash command: $TOOL_INPUT.command\n\nCheck for:\n- Dangerous commands (rm -rf /, dd, etc)\n- Command injection attempts\n- Unsafe flags\n\nReturn 'allow', 'deny', or 'warn' with explanation."
        }
      ]
    }
  ]
}
```

**Multi-layer protection:**
```json
{
  "PreToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/quick-check.sh"
        },
        {
          "type": "prompt",
          "prompt": "Additional validation: is this file write safe?"
        }
      ]
    }
  ]
}
```

**Context loading:**
```json
{
  "SessionStart": [
    {
      "matcher": "*",
      "hooks": [
        {
          "type": "command",
          "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/load-context.sh"
        }
      ]
    }
  ]
}
```

#### Best Practices для Hooks

**✅ Do:**
- Используйте prompt-based hooks для сложной логики
- Валидируйте input в command hooks
- Используйте `${CLAUDE_PLUGIN_ROOT}` для portable paths
- Предоставляйте clear error messages
- Тестируйте hooks перед релизом
- Документируйте сложные patterns в README
- Используйте timeouts для долгих операций
- Обрабатывайте ошибки gracefully

**❌ Don't:**
- Не полагайтесь на порядок выполнения hooks
- Не блокируйте без clear reason
- Не используйте hardcoded paths
- Не злоупотребляйте "*" matcher
- Не забывайте про exit codes в command hooks
- Не делайте hooks слишком сложными

#### Security Best Practices

**Input validation:**
```bash
#!/bin/bash
input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name')

# Всегда валидируйте input
if [[ ! "$tool_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
  echo '{"decision": "deny", "reason": "Invalid tool name"}' >&2
  exit 2
fi
```

**Path validation:**
```json
{
  "type": "prompt",
  "prompt": "Validate path: $TOOL_INPUT.file_path\n\nCheck:\n1. No path traversal (..)\n2. Not in system directories (/etc, /sys, /proc)\n3. Not credential files (.env, credentials)\n\nReturn 'allow' or 'deny'."
}
```

**Command sanitization:**
```bash
# Санитизируйте команды перед выполнением
sanitize_command() {
  local cmd="$1"
  # Remove dangerous flags
  cmd="${cmd//--rf/}"
  cmd="${cmd//-f/}"
  echo "$cmd"
}
```

#### Performance Considerations

**Optimization tips:**
- Используйте command hooks для быстрых проверок
- Prompt hooks только для сложной логики
- Кэшируйте результаты где возможно
- Избегайте долгих операций в hooks
- Используйте timeouts для внешних вызовов

**Hook timeouts:**
- PreToolUse: 5s default
- PostToolUse: 2s default
- Stop: 3s default
- Other events: 1s default

#### Testing Hooks

**Unit testing:**
```bash
# Тест с mock input
echo '{"tool_name": "Write", "tool_input": {...}}' | \
  bash hooks/validate.sh
```

**Integration testing:**
```bash
# Тест в реальном окружении
cc --plugin-dir /path/to/plugin

# Выполните действие которое триггерит hook
# Проверьте результат
```

**Validation:**
```bash
# Валидация JSON схемы
./validate-hook-schema.sh hooks/hooks.json

# Проверка синтаксиса
jq . hooks/hooks.json
```

#### Troubleshooting

**Hook не срабатывает:**
- Проверьте структуру `{"hooks": {...}}`
- Убедитесь что event name корректен
- Проверьте matcher pattern
- Посмотрите логи Claude Code

**Command hook fails:**
- Проверьте executable rights: `chmod +x`
- Убедитесь что используете正确的 exit codes
- Проверьте stderr output
- Протестируйте standalone

**Prompt hook не работает:**
- Проверьте переменные в prompt ($TOOL_INPUT, etc)
- Убедитесь что prompt instructions ясны
- Протестируйте с простыми cases

**Критически важно:**
- ✅ Корневой ключ ДОЛЖЕН быть `"hooks"`
- ✅ Prefer prompt-based hooks для сложной логики
- ✅ Используйте `${CLAUDE_PLUGIN_ROOT}` в командах
- ✅ Валидируйте hooks.json перед релизом
- ✅ Тестируйте hooks в различных сценариях

### MCP Integration

**Назначение:** Подключение к Model Context Protocol серверам

**Формат .mcp.json:**
```json
{
  "mcpServers": {
    "server-name": {
      "type": "http",
      "url": "http://localhost:8888/mcp",
      "headers": {
        "Content-Type": "application/json"
      }
    }
  }
}
```

**Типы серверов:**
- `stdio` - Локальный процесс (npm пакеты, локальные серверы)
- `http` - REST API (веб-сервисы)
- `sse` - Server-Sent Events (OAuth сервисы)
- `websocket` - WebSocket (real-time)

**Environment variables:**
```json
{
  "command": "python",
  "args": ["-m", "my_mcp_server"],
  "env": {
    "DATABASE_URL": "${DB_URL}",
    "API_KEY": "${API_KEY}"
  }
}
```

**Важно:**
- ✅ Документируйте требуемые переменные в README
- ✅ Используйте HTTPS для production
- ❌ НЕ храните credentials в конфиге

---

## 📚 Plugin Reference

### Plugin Manifest (plugin.json) - Полный Reference

**Расположение:** `.claude-plugin/plugin.json`

**Обязательные поля:**
```json
{
  "name": "plugin-name"
}
```

**Рекомендуемые поля:**
```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Brief explanation of plugin purpose",
  "author": {
    "name": "Author Name",
    "email": "author@example.com",
    "url": "https://example.com"
  },
  "homepage": "https://docs.example.com",
  "repository": "https://github.com/user/plugin-name",
  "license": "MIT",
  "keywords": ["keyword1", "keyword2"]
}
```

**Опциональные пути к компонентам:**
```json
{
  "name": "plugin-name",
  "version": "2.3.1",
  "description": "Comprehensive plugin description",
  "commands": ["./commands", "./admin-commands"],
  "agents": "./specialized-agents",
  "hooks": "./config/hooks.json",
  "mcpServers": "./.mcp.json"
}
```

**Полная спецификация полей:**

| Поле | Тип | Обязательное | Описание |
|------|-----|-------------|----------|
| `name` | string | ✅ | Имя плагина (kebab-case) |
| `version` | string | ❌ | Semantic versioning (MAJOR.MINOR.PATCH) |
| `description` | string | ❌ | Краткое описание |
| `author` | object | ❌ | Информация об авторе |
| `author.name` | string | ❌ | Имя автора |
| `author.email` | string | ❌ | Email автора |
| `author.url` | string | ❌ | URL автора |
| `homepage` | string | ❌ | Homepage URL |
| `repository` | string/object | ❌ | Репозиторий |
| `repository.type` | string | ❌ | Тип (git) |
| `repository.url` | string | ❌ | URL репозитория |
| `license` | string | ❌ | Лицензия (MIT, Apache-2.0, etc) |
| `keywords` | array | ❌ | Ключевые слова для поиска |
| `commands` | array/string | ❌ | Путь к commands директории |
| `agents` | string | ❌ | Путь к agents директории |
| `hooks` | string | ❌ | Путь к hooks.json |
| `mcpServers` | string | ❌ | Путь к .mcp.json |

**Пример полного manifest:**
```json
{
  "name": "enterprise-devops",
  "version": "2.3.1",
  "description": "Comprehensive DevOps automation for enterprise CI/CD pipelines",
  "author": {
    "name": "DevOps Team",
    "email": "devops@company.com",
    "url": "https://company.com/devops"
  },
  "homepage": "https://docs.company.com/plugins/devops",
  "repository": {
    "type": "git",
    "url": "https://github.com/company/devops-plugin.git"
  },
  "license": "Apache-2.0",
  "keywords": [
    "devops",
    "ci-cd",
    "automation",
    "kubernetes",
    "docker",
    "deployment"
  ],
  "commands": ["./commands", "./admin-commands"],
  "agents": "./specialized-agents",
  "hooks": "./config/hooks.json",
  "mcpServers": "./.mcp.json"
}
```

### Component Reference

#### Commands Reference

**Frontmatter поля:**

| Поле | Тип | Обязательное | Значения |
|------|-----|-------------|----------|
| `description` | string | ✅ | Любая строка |
| `allowed-tools` | array/string | ❌ | ["Bash", "Read", "Write", ...] |
| `argument-hint` | string | ❌ | "[arg1] [arg2] [--option]" |
| `model` | string | ❌ | "sonnet", "opus", "haiku", "inherit" |
| `disable-model-invocation` | boolean | ❌ | true, false |

**Special variables:**
- `$1`, `$2`, ... - Позиционные аргументы
- `$ARGUMENTS` - Все аргументы
- `@path/to/file` - Содержимое файла
- `!`command`` - Bash execution
- `${CLAUDE_PLUGIN_ROOT}` - Путь к плагину

**Allowed tools values:**
- `Bash` - Все bash команды
- `Bash(git:*)` - Git команды только
- `Bash(git:commit, git:push)` - Конкретные команды
- `Read` - Чтение файлов
- `Write` - Запись файлов
- `Edit` - Редактирование файлов
- `Grep` - Поиск в файлах
- `Glob` - Поиск файлов
- `AskUserQuestion` - Интерактивные вопросы

#### Agents Reference

**Frontmatter поля:**

| Поле | Тип | Обязательное | Значения |
|------|-----|-------------|----------|
| `name` | string | ✅ | kebab-case, 3-50 символов |
| `description` | string | ✅ | С `<example>` блоками |
| `model` | string | ✅ | "inherit", "sonnet", "opus", "haiku" |
| `color` | string | ✅ | "blue", "cyan", "green", "yellow", "magenta", "red" |
| `tools` | array | ❌ | ["Read", "Bash", ...] |

**Description формат:**
```yaml
description: Use this agent when... Examples:

<example>
Context: [Ситуация]
user: "[Запрос]"
assistant: "[Ответ]"
<commentary>
[Почему триггер]
</commentary>
</example>
```

#### Skills Reference

**Frontmatter поля:**

| Поле | Тип | Обязательное | Значения |
|------|-----|-------------|----------|
| `name` | string | ✅ | kebab-case |
| `description` | string | ✅ | С trigger phrases |
| `model` | string | ✅ | "sonnet", "haiku" |
| `version` | string | ❌ | Semantic versioning |

**Description формат:**
- Third-person: "This skill should be used when..."
- Concrete phrases: "asks to 'create a hook'"
- Specific triggers: exact user queries

#### Hooks Reference

**Hook события:**
- `PreToolUse` - Перед инструментом
- `PostToolUse` - После инструмента
- `Stop` - Перед завершением
- `SubagentStop` - После агента
- `SessionStart` - Начало сессии
- `SessionEnd` - Конец сессии
- `UserPromptSubmit` - Отправка запроса
- `PreCompact` - Перед сжатием
- `Notification` - Уведомления

**Hook input fields:**
```json
{
  "session_id": "uuid",
  "transcript_path": "/path",
  "cwd": "/current/dir",
  "permission_mode": "ask|allow",
  "hook_event_name": "EventName"
}
```

**Hook output format:**
```json
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "Status message"
}
```

#### MCP Servers Reference

**MCP server types:**
- `stdio` - Локальный процесс
- `http` - REST API
- `sse` - Server-Sent Events
- `websocket` - WebSocket

**.mcp.json format:**
```json
{
  "mcpServers": {
    "server-name": {
      "type": "stdio|http|sse|websocket",
      "command": "node",
      "args": ["server.js"],
      "url": "http://localhost:8888/mcp",
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```

### Path Resolution

**Относительные пути:**
```json
{
  "commands": "./commands",           // От plugin.json
  "agents": "./agents",               // От plugin.json
  "hooks": "./config/hooks.json"      // От plugin.json
}
```

**В компонентах:**
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/script.sh  # Абсолютный путь к plugin root
${CLAUDE_PLUGIN_ROOT}/templates/tmpl.md  # Абсолютный путь к файлам
```

**Auto-discovery paths:**
```
plugin-name/
├── commands/*.md           # Автоматически обнаруживаются
├── agents/*.md             # Автоматически обнаруживаются
├── skills/*/SKILL.md       # Автоматически обнаруживаются
└── hooks/hooks.json        # Явная ссылка в plugin.json
```

### Plugin Lifecycle

**1. Discovery:**
- Сканирование `.claude-plugin/plugin.json`
- Чтение manifest
- Определение компонентов

**2. Initialization:**
- Загрузка component metadata
- Регистрация commands
- Настройка hooks
- Подключение MCP servers

**3. Execution:**
- Command invocation
- Agent triggering
- Skill loading
- Hook execution

**4. Cleanup:**
- SessionEnd hooks
- MCP server disconnect
- Resource cleanup

### Plugin Capabilities

**Что МОЖут плагины:**
- ✅ Добавлять пользовательские команды
- ✅ Создавать автономных агентов
- ✅ Предоставлять специализированные знания
- ✅ Реагировать на события
- ✅ Интегрировать внешние сервисы
- ✅ Модифицировать поведение Claude
- ✅ Валидировать операции
- ✅ Логировать действия

**Что НЕ МОГУТ плагины:**
- ❌ Изменять core Claude поведение
- ❌ Получать доступ к другим сессиям
- ❌ Модифицировать системные файлы без разрешения
- ❌ Обходить permission mode
- ❌ Получать доступ к credential storage

### Plugin Limitations

**Ограничения:**
- Максимум 100 команд на плагин
- Максимум 50 агентов на плагин
- Максимум 20 skills на плагин
- Hook execution timeout: 5s
- MCP server startup timeout: 10s
- Maximum plugin size: 10MB

**Performance:**
- Skills load on-demand
- Agents trigger proactively
- Hooks execute synchronously
- Commands execute immediately

---

## 🎨 Конвенции и Best Practices

### Naming Conventions

| Тип | Формат | Примеры |
|-----|--------|---------|
| **Plugin name** | kebab-case | `hindsight`, `plugin-dev`, `commit-commands` |
| **Command name** | kebab-case | `init`, `create-plugin`, `deploy-app` |
| **Agent name** | kebab-case | `memory-keeper`, `pr-quality-reviewer` |
| **Skill name** | kebab-case | `memory-workflow`, `hook-development` |
| **Directories** | kebab-case | `commands/`, `agents/`, `skills/` |

### Writing Style Guidelines

**Для всех компонентов:**
- ✅ **Third-person** - "This skill should be used when..."
- ✅ **Imperative form** - "Create X", not "You should create X"
- ✅ **Concrete descriptions** - конкретные фразы
- ❌ **First-person** - не "I help you..."
- ❌ **Second-person** - не "Use this when you need..."

### Portability Principles

**Всегда используйте `${CLAUDE_PLUGIN_ROOT}`:**

```markdown
# ❌ ПЛОХО
!`bash /Users/user/plugins/hindsight/scripts/init.sh`

# ✅ ХОРОШО
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/init.sh`
```

### Security Best Practices

1. **Credentials:**
   - ✅ Environment variables: `${API_KEY}`
   - ❌ НЕ в plugin.json
   - ❌ НЕ в .md файлах

2. **Code execution:**
   - ✅ Валидировать входные данные
   - ✅ Ограничивать `allowed-tools`
   - ✅ Использовать hooks для security

3. **Network:**
   - ✅ Использовать HTTPS
   - ✅ Timeout для запросов

### File Organization

**Минимальный плагин:**
```
minimal-plugin/
├── .claude-plugin/plugin.json
└── README.md
```

**Стандартный плагин:**
```
standard-plugin/
├── .claude-plugin/plugin.json
├── commands/
├── skills/
└── README.md
```

**Полнофункциональный плагин:**
```
full-plugin/
├── .claude-plugin/plugin.json
├── commands/
├── agents/
├── skills/
├── hooks/
├── scripts/
├── .mcp.json
└── README.md
```

### Testing Strategy

```bash
# Локальное тестирование
cc --plugin-dir /path/to/plugin

# Или symbolic link
ln -s /path/to/plugin ~/.claude/plugins/plugin-name
```

**Checklist:**
- [ ] Plugin загружается без ошибок
- [ ] Команды работают
- [ ] Skills загружаются
- [ ] Agents вызываются
- [ ] Hooks срабатывают
- [ ] MCP подключается

---

## 🔧 Технические детали

### ${CLAUDE_PLUGIN_ROOT}

**Назначение:** Переменная окружения с путём к корню плагина

**Где использовать:**
- Bash команды в commands
- Hook scripts
- File references
- MCP configurations

**Примеры:**
```bash
# В command
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/init.sh`

# В hook
"command": "bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh"

# В MCP
"args": ["${CLAUDE_PLUGIN_ROOT}/server.js"]
```

### Progressive Disclosure

**Three-level system:**

```
Level 1: Metadata (всегда загружен)
  ├─ name
  ├─ description с trigger phrases
  └─ version

Level 2: SKILL.md (при триггере)
  ├─ 1,500-2,000 слов essentials
  ├─ Imperative form
  └─ Ссылки на references

Level 3: References/Examples (по требованию)
  ├─ references/patterns.md
  ├─ examples/workflow.md
  └─ scripts/utils.sh
```

### Error Handling

**В bash скриптах:**
```bash
#!/bin/bash
set -e  # Exit on error

# Проверка зависимостей
if ! command -v jq &> /dev/null; then
    echo "❌ jq is required but not installed"
    exit 1
fi

# Понятные сообщения
echo "✅ Bank initialized successfully"
echo "⚠️  Server unavailable"
echo "❌ Failed to connect"
```

---

## 📤 Стили вывода (Output Styles)

### Основные принципы

**Хороший вывод должен быть:**
- ✅ **Ясным** - пользователю сразу понятно что произошло
- ✅ **Структурированным** - информация организована логически
- ✅ **Консистентным** - одинаковый стиль во всём плагине
- ✅ **Информативным** - достаточно деталей, но не перегружен
- ✅ **Действенным** - пользователь знает что делать дальше

### Как писать Output Format для агентов

**Структура секции Output Format:**

```markdown
## Output Format:
Provide results as:
- **Category 1**: Что включать
- **Category 2**: Что включать
- **Category 3**: Что включать

For each item, include:
- File and line number (if applicable)
- Severity or priority
- Actionable recommendation
```

**Категории должны быть:**
- **Mutually exclusive** - элемент попадает только в одну категорию
- **Hierarchical** - от критического к информативному
- **Actionable** - каждая категория предполагает действие

**Примеры категорий для разных типов агентов:**

| Тип агента | Категории |
|------------|-----------|
| Code reviewer | Critical, Important, Suggestions, Strengths |
| Security scanner | Critical, High, Medium, Low, Info |
| Performance analyzer | Bottlenecks, Warnings, Optimizations, Good |
| Documentation | Missing, Outdated, Complete, Excellent |

### Как настраивать вывод команд

**Базовая структура вывода команды:**

```markdown
## [Command Name] Results

### Summary
[Одна строка с emoji и статусом]

### Details
[Структурированная информация]

### Next Steps
[Конкретные действия]
```

**Настройка через frontmatter:**

```markdown
---
description: Brief description for /help
model: sonnet                    # Модель влияет на стиль вывода
disable-model-invocation: false  # false = Claude форматирует вывод
---

# Инструкции для Claude

Provide results in the following format:
1. Start with summary
2. Group findings by category
3. Include actionable next steps
```

### Конфигурация emoji и символов

**Стандартные индикаторы статуса:**

| Emoji | Когда использовать | Консистентность |
|-------|-------------------|-----------------|
| ✅ | Успех, завершение | Во всех плагинах |
| ❌ | Ошибка, failure | Во всех плагинах |
| ⚠️ | Предупреждение | Во всех плагинах |
| 📝 | Информация, создание | Опционально |
| 🔍 | Анализ, поиск | Опционально |
| 🚀 | Деплой, запуск | Опционально |

**Правила использования:**
- 1-2 emoji на блок информации
- Всегда в начале строки для сканируемости
- Одинаковые emoji для одних и тех операций
- Не злоупотребляйте (не более 20% строк)

### Форматирование структурированных данных

**Для списков с статусом:**
```markdown
✓ Item one completed
✓ Item two completed
✗ Item three failed
⚠ Item four warning
```

**Для таблиц:**
```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Data     | 1,234    | ✅       |
```

- Выравнивайте колонки визуально
- Числа по правому краю
- Статус по центру или левому краю

### Настройка progress индикаторов

**Для одношаговых операций:**
```markdown
📊 Processing...
✓ Found 1,234 items
✓ Processed 1,234 items
⏱️ Completed in 2.3s
```

**Для многошаговых операций:**
```markdown
[1/3] Step one...    ✅
[2/3] Step two...    ⏳
[3/3] Step three...  ⏸️
```

**Когда показывать progress:**
- Операции дольше 1 секунды
- Многошаговые процессы
- Пакетная обработка файлов

### Настройка сообщений об ошибках

**Обязательные элементы:**
1. **Чёткое описание** - что именно пошло не так
2. **Почему важно** - влияние на операцию
3. **Как исправить** - конкретные шаги
4. **Технические детали** (опционально) - для debugging

**Структура:**
```markdown
❌ **[Error Name]: [Brief Description]**

**What happened:**
[Specific error description]

**Why it matters:**
[Impact on operation]

**How to fix:**
1. [Step one]
2. [Step two]
3. [Step three]

**Technical details:** (опционально)
- Error code: XXX
- Location: file:line
```

### Настройка success сообщений

**Обязательные элементы:**
1. **Что сделано** - конкретные действия
2. **Результат** - что получено
3. **Next steps** - что делать дальше

**Структура:**
```markdown
✅ **[Operation] Completed Successfully!**

**What was done:**
- [Action 1]
- [Action 2]
- [Action 3]

**Result:**
[Summary of outcome]

**Next steps:**
1. [Action one]
2. [Action two]
```

### Вывод для хуков

**JSON формат с systemMessage:**

```json
{
  "hookSpecificOutput": {
    "permissionDecision": "allow|deny|ask"
  },
  "systemMessage": "✅ Status message here"
}
```

**Настройка systemMessage:**
- Начинайте с emoji статуса
- Будьте краткими (одна строка)
- Информативными

**PreToolUse output:**
```json
{
  "hookSpecificOutput": {
    "permissionDecision": "allow",
    "updatedInput": {}
  },
  "systemMessage": "✅ Validated: safe operation"
}
```

**Stop hook output:**
```json
{
  "decision": "approve|block",
  "reason": "Explanation",
  "systemMessage": "✅ All checks passed"
}
```

### Best Practices

**✅ Do:**
- Используйте emoji в начале строк
- Выравнивайте колонки в таблицах
- Форматируйте числа (1,234,567)
- Показывайте progress для долгих операций
- Подтверждайте успешные операции
- Давайте конкретные next steps

**❌ Don't:**
- Злоупотребляйте emoji (>20% строк)
- Делайте строки >80 chars в таблицах
- Смешивайте форматы чисел
- Оставляйте без next steps
- Показывайте technical details без необходимости

---

## 🚀 Разработка и тестирование

### Локальная разработка

**1. Структура:**
```
~/.claude/plugins/my-plugin/
├── .claude-plugin/plugin.json
├── commands/
└── README.md
```

**2. Тестирование:**
```bash
# Запуск с локальным плагином
cc --plugin-dir /path/to/my-plugin

# Или symbolic link
ln -s /path/to/my-plugin ~/.claude/plugins/my-plugin
```

**3. Итерации:**
- Изменения в плагине
- Перезапуск Claude Code
- Проверка функциональности

### Валидация

**Hooks validation:**
```bash
./validate-hook-schema.sh hooks/hooks.json
```

**Validation checklist:**
- JSON syntax валиден
- Обязательные поля присутствуют
- Event names корректны
- Hook types валидны
- Timeout в допустимом диапазоне
- Hardcoded paths отсутствуют

---

## 📦 Публикация

### Подготовка репозитория

```bash
git init
git add .
git commit -m "Initial commit"

git remote add origin https://github.com/user/my-plugin.git
git push -u origin main
```

### Marketplace структура

```
username/my-marketplace/
├── .claude-plugin/marketplace.json
└── plugins/
    └── my-plugin/
        └── .claude-plugin/plugin.json
```

### Версионирование

**Semantic Versioning:**
- `MAJOR` - breaking changes
- `MINOR` - новые features
- `PATCH` - bug fixes

```bash
# Обновление версии
"version": "1.1.0"  # Было 1.0.0
```

### Установка пользователями

```bash
# Из GitHub
/plugin marketplace add username/my-marketplace
/plugin install my-plugin@username-my-marketplace

# Короткий формат
/plugin install my-plugin
```

---

## 🎓 Уроки разработки

### Ключевые выводы

1. **Description агента требует `<example>` блоков**
   - Это ОФИЦИАЛЬНЫЙ формат
   - Context, user, assistant, commentary
   - 2-4 примера

2. **Description skill должен быть конкретным**
   - ❌ "Use this skill when working with hooks"
   - ✅ "This skill should be used when the user asks to 'create a hook'"

3. **Third-Person Writing Style**
   - ✅ "This skill should be used when..."
   - ❌ "Use this when you need..."

4. **${CLAUDE_PLUGIN_ROOT} обязателен**
   - Для всех путей к файлам
   - Иначе плагин не portable

5. **Progressive Disclosure**
   - Level 1: Metadata
   - Level 2: SKILL.md essentials
   - Level 3: References/Examples

6. **Auto-Discovery работает автоматически**
   - Никакой ручной регистрации не нужно

---

## ✅ Validation Checklist

### Plugin Structure
- [ ] `.claude-plugin/plugin.json` существует
- [ ] Все директории на правильном уровне
- [ ] Используется kebab-case
- [ ] README.md присутствует

### Commands
- [ ] Frontmatter валиден
- [ ] Описания в третьем лице
- [ ] `${CLAUDE_PLUGIN_ROOT}` используется
- [ ] `allowed-tools` ограничен

### Agents
- [ ] `<example>` блоки присутствуют
- [ ] 2-4 примера
- [ ] Clear triggers

### Skills
- [ ] Concrete trigger phrases
- [ ] Third-person style
- [ ] SKILL.md lean
- [ ] References разделены

### Hooks
- [ ] `{"hooks": {...}}` структура
- [ ] Matcher patterns корректны
- [ ] `${CLAUDE_PLUGIN_ROOT}` в командах

### MCP
- [ ] `.mcp.json` валиден
- [ ] Environment variables documented

### Testing
- [ ] Plugin загружается
- [ ] Все команды работают
- [ ] Skills загружаются
- [ ] Agents вызываются
- [ ] Hooks срабатывают
- [ ] Portable paths работают

---

## 📖 Дополнительные ресурсы

### Официальная документация

- [Plugin Development](https://code.claude.com/docs/en/discover-plugins)
- [Sub-agents](https://code.claude.com/docs/en/sub-agents)
- [Slash Commands](https://code.claude.com/docs/en/slash-commands)
- [Hooks Guide](https://code.claude.com/docs/en/hooks-guide)

### Примеры из official plugins

В `~/.claude/plugins/marketplaces/claude-plugins-official/`:
- `plugin-dev` - Создание плагинов
- `commit-commands` - Git workflow
- `pr-review-toolkit` - Review агенты

---

_Последнее обновление: 2026-01-19_
_Версия документации: 2.0_
