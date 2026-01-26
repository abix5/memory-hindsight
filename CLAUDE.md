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

#### Best Practices для команд

**✅ Do:**
- Пишите инструкции FOR Claude, not FOR users
- Используйте `${CLAUDE_PLUGIN_ROOT}` для portable paths
- Ограничивайте `allowed-tools` для безопасности
- Предоставляйте清晰的 следующий шаги
- Используйте bash execution для получения данных
- Валидируйте входные аргументы

**❌ Don't:**
- Не включайте `name` в frontmatter
- Не пишите описания "This command will..."
- Не используйте hardcoded paths
- Не разрешайте все инструменты без необходимости
- Не оставляйте пользователя без clear next steps

#### Когда использовать Commands vs Agents vs Skills

| Компонент | Когда использовать | Пример |
|-----------|-------------------|---------|
| **Command** | Пользователь явно вызывает действие | `/deploy`, `/test`, `/review` |
| **Agent** | Автономная многошаговая задача | Анализ кода, генерация документации |
| **Skill** | Справочная информация | Best practices, API reference |

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

**Важно:**
- ❌ **НЕ включать** поле `name` в frontmatter - имя берётся из названия файла
- ✅ Команды должны **инструктировать Claude**, а не пользователя
- ✅ Bash execution выполняется **до** того как Claude видит промпт
- ✅ Всегда использовать `${CLAUDE_PLUGIN_ROOT}` для путей к скриптам

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

#### Hook Execution Order

**Порядок выполнения:**
1. Hooks выполняются в порядке определения в массиве
2. Если один hook блокирует, следующие не выполняются
3. Hooks одного события не зависят друг от друга

**Hook priority:**
- Hooks из плагинов выполняются в алфавитном порядке имени плагина
- Project hooks (`.claude/hooks.json`) выполняются после plugin hooks

#### Best Practices Summary

**Security:**
- Всегда валидируйте input в command hooks
- Проверяйте пути на traversal (..) и системные директории
- Используйте prompt hooks для сложной логики

**Performance:**
- Command hooks для быстрых проверок
- Prompt hooks для сложной логики
- Hook timeouts: PreToolUse 5s, PostToolUse 2s, Stop 3s

**Testing:**
```bash
# Unit test
echo '{"tool_name": "Write"}' | bash hooks/validate.sh

# Integration test
cc --plugin-dir /path/to/plugin

# Validation
jq . hooks/hooks.json
```

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

**Структура плагина:**
```
my-plugin/
├── .claude-plugin/plugin.json  # Обязательный
├── README.md                    # Обязательный
├── commands/                    # Опционально
├── agents/                      # Опционально
├── skills/                      # Опционально
├── hooks/                       # Опционально
└── scripts/                     # Опционально
```

### Testing Strategy

```bash
# Локальное тестирование
cc --plugin-dir /path/to/plugin
```

---

## 🔧 Технические детали

### ${CLAUDE_PLUGIN_ROOT}

**Назначение:** Переменная окружения с путём к корню плагина

**Использование:**
```bash
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/init.sh`
"command": "bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh"
```

### Progressive Disclosure

**Трехуровневая система для Skills:**
- **Level 1:** Metadata (name, description, version)
- **Level 2:** SKILL.md (1,500-2,000 слов essentials)
- **Level 3:** References/Examples (по требованию)

---

## 🚀 Разработка и тестирование

### Локальная разработка

```bash
# Запуск с локальным плагином
cc --plugin-dir /path/to/my-plugin
```

**Итерации:** Изменения → Перезапуск Claude Code → Проверка

### Валидация

```bash
# Hooks validation
./validate-hook-schema.sh hooks/hooks.json

# JSON syntax
jq . .claude-plugin/plugin.json
```

---

## 📦 Публикация

### Marketplace структура

```
username/my-marketplace/
├── .claude-plugin/marketplace.json
└── plugins/
    └── my-plugin/
        └── .claude-plugin/plugin.json
```

### Версионирование

**Semantic Versioning:** MAJOR.MINOR.PATCH
- MAJOR - breaking changes
- MINOR - новые features
- PATCH - bug fixes

### Установка

```bash
/plugin marketplace add username/my-marketplace
/plugin install my-plugin@username-my-marketplace
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

_Последнее обновление: 2026-01-26_
_Версия документации: 2.1_
