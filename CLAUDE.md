# Hindsight Plugin Development Guide

> База знаний для разработки плагинов Claude Code с интеграцией Hindsight

## О проекте

Этот плагин интегрирует [Hindsight](https://github.com/vectorize-io/hindsight) memory bank с Claude Code, позволяя хранить и извлекать важные решения разработки между сессиями.

## Структура репозитория

```
hindsight-marketplace/
├── .claude-plugin/
│   └── marketplace.json              # Описание marketplace
├── plugins/
│   └── hindsight/                    # Сам плагин
│       ├── .claude-plugin/
│       │   └── plugin.json           # Манифест плагина
│       ├── commands/                 # Slash-команды
│       │   ├── init.md
│       │   ├── retain.md
│       │   ├── recall.md
│       │   └── reflect.md
│       ├── scripts/                  # Bash скрипты
│       │   ├── get-bank-id.sh
│       │   └── init-bank.sh
│       ├── agents/                   # Специализированные агенты
│       │   └── memory-keeper.md
│       ├── skills/                   # Навыки для Claude
│       │   └── memory-workflow/
│       │       ├── SKILL.md
│       │       └── references/
│       ├── hooks/                    # Event hooks
│       │   └── hooks.json
│       ├── .mcp.json                 # MCP server конфигурация
│       ├── README.md
│       └── USAGE.md
├── CLAUDE.md                         # Этот файл
└── .gitignore

```

---

## 🎯 Архитектура плагина

### Команды (Slash Commands)

**Назначение:** Пользовательские команды, вызываемые через `/plugin-name:command-name`

**Ключевые особенности:**
- Выполняют bash-команды через синтаксис `!`команда``
- Получают результаты до выполнения промпта
- Используют `${CLAUDE_PLUGIN_ROOT}` для портативности
- Содержат промпт-инструкции для Claude о том, как интерпретировать результаты

**Структура команды:**
```markdown
---
description: Краткое описание команды
allowed-tools: ["Bash", "Read", "Write"]  # Разрешенные инструменты
argument-hint: "<arg1> [--option]"        # Подсказка аргументов
---

## Выполнение bash команд

Получение данных: !`bash ${CLAUDE_PLUGIN_ROOT}/scripts/script.sh $ARGUMENTS`

---

## Your Task (Инструкции для Claude)

Что делать с полученными результатами...
```

**Важно:**
- ❌ **НЕ включать** поле `name` в frontmatter - имя берётся из названия файла
- ✅ Команды должны **инструктировать Claude**, а не пользователя
- ✅ Bash execution выполняется **до** того как Claude видит промпт
- ✅ Всегда использовать `${CLAUDE_PLUGIN_ROOT}` для путей к скриптам

**Наш подход:**
1. Команда выполняет `hindsight` CLI через bash
2. Получает сырые результаты (JSON/текст)
3. Claude интерпретирует результаты и представляет пользователю

### Скрипты (Scripts)

**Назначение:** Вспомогательные bash-скрипты для команд

**Требования:**
- ✅ Исполняемый флаг (`chmod +x`)
- ✅ Shebang `#!/bin/bash`
- ✅ Обработка ошибок (`set -e`)
- ✅ Проверка всех условий (файлы существуют, сервер доступен и т.д.)
- ✅ Понятный вывод (с emoji для статуса: ✅ ❌ ⚠️ 📝 🔍)

**Наши скрипты:**

1. **`get-bank-id.sh`** - Извлечение bank_id из конфига
   - Читает `.claude/hindsight.json`
   - Парсит JSON через grep/sed (без зависимости от jq)
   - Выдаёт ошибку если конфиг не найден

2. **`init-bank.sh`** - Инициализация проекта
   - Автоопределение bank_id из git remote или имени папки
   - Проверка доступности Hindsight сервера
   - Создание/подключение к банку памяти
   - Генерация конфига и документации
   - Добавление в .gitignore

### Агенты (Agents)

**Назначение:** Автономные подпроцессы для сложных многошаговых задач

**Ключевые особенности:**
- Autonomous operation (работают самостоятельно)
- Специализация на конкретной задаче
- Могут вызываться автоматически Claude на основе контекста

**Структура агента:**
```markdown
---
name: agent-name                      # kebab-case, 3-50 символов
description: Когда использовать этого агента. Use proactively when...
model: inherit | sonnet | opus | haiku
color: blue | cyan | green | yellow | magenta | red
tools: ["Read", "Bash", "Grep"]       # Ограничение инструментов (опционально)
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

**Критически важно:**
- ✅ **Description должен быть однострочным** (может быть длинным, но без переносов и сложных блоков)
- ❌ НЕ включать `<example>` блоки в description (это для старого формата)
- ✅ Четкие триггеры: "Use proactively when X happens"
- ✅ Model обычно `inherit` или `sonnet` для качественной работы
- ✅ Tools - минимум необходимых (принцип наименьших привилегий)

**Наш агент: memory-keeper**
- Специализация: Идентификация и сохранение важных решений
- Триггеры: Архитектурные решения, технологические выборы, баги, компромиссы
- Model: sonnet (для качественного анализа контекста)
- Tools: Bash, Read (для выполнения hindsight CLI)

### Skills (Навыки)

**Назначение:** Знания и рекомендации, которые Claude применяет автоматически при совпадении контекста

**Отличие от команд и агентов:**
- Commands - пользователь вызывает явно
- Agents - Claude запускает для выполнения задач
- Skills - Claude использует как справочную информацию

**Структура skill:**
```markdown
---
name: skill-name                      # kebab-case
description: Когда и как использовать этот skill. Триггерные слова и фразы...
model: sonnet | haiku                 # Модель для загрузки skill
---

# Skill Content

Подробные инструкции, best practices, примеры...
```

**Важно:**
- ✅ Name в kebab-case (не "Skill Name", а "skill-name")
- ✅ Description содержит триггерные ключевые слова
- ✅ Model обычно `sonnet` для сложных навыков
- ❌ НЕ включать поле `version` (не входит в официальную схему)

**Наш skill: memory-workflow**
- Руководство по работе с Hindsight memory bank
- Когда вызывать recall, retain, reflect
- Категории памяти и best practices
- Триггеры: "retain", "recall", "memory bank", "past decisions"

### Hooks (Хуки)

**Назначение:** Автоматическая реакция на события в Claude Code

**Типы событий:**
- `PreToolUse` - Перед использованием инструмента
- `PostToolUse` - После использования инструмента
- `Stop` - Перед завершением сессии
- `SubagentStop` - Когда завершается подагент
- `SessionStart` - Начало сессии
- `SessionEnd` - Конец сессии
- `UserPromptSubmit` - Отправка промпта пользователем
- `PreCompact` - Перед сжатием истории
- `Notification` - Системное уведомление

**Структура hooks.json:**
```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Инструкция для Claude что делать..."
          }
        ]
      }
    ]
  }
}
```

**Критически важно:**
- ✅ Корневой ключ ДОЛЖЕН быть `"hooks"`
- ❌ НЕ использовать `{"Stop": [...]}` напрямую
- ✅ Правильно: `{"hooks": {"Stop": [...]}}`

**Наш хук: Stop**
- Проверяет разговор на наличие важных решений
- Предлагает сохранить их перед завершением сессии
- Не навязывает, только предлагает

### MCP Integration

**Назначение:** Подключение к Model Context Protocol серверам для внешних сервисов

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
- `stdio` - Локальный процесс (для npm пакетов, локальных серверов)
- `http` - REST API (для веб-сервисов)
- `sse` - Server-Sent Events (для OAuth сервисов)
- `websocket` - WebSocket (для real-time)

**Наша конфигурация:**
- Подключение к локальному Hindsight серверу через HTTP
- URL: http://localhost:8888/mcp
- Предоставляет MCP инструменты для прямого доступа к памяти

---

## 🔧 Технические детали

### Конфигурация проекта

**Два файла в `.claude/`:**

1. **`hindsight.json`** (git-ignored) - Простой конфиг:
```json
{
  "bank_id": "my-project",
  "api_url": "http://localhost:8888",
  "default_context": "decisions"
}
```

2. **`hindsight-guide.md`** (git-committed) - Инструкции для команды:
```markdown
# Hindsight Memory Bank Guide

## Memory Categories
- architecture - Architectural decisions
- tech-stack - Technology choices
...
```

**Почему два файла?**
- `hindsight.json` - персональные настройки (bank_id может отличаться)
- `hindsight-guide.md` - общие инструкции для всей команды (одинаковые для всех)

### Парсинг JSON без зависимостей

**Проблема:** Не хотим зависеть от jq

**Решение:** grep + sed для извлечения значений:
```bash
BANK_ID=$(grep -o '"bank_id"[[:space:]]*:[[:space:]]*"[^"]*"' "$FILE" | \
          sed 's/.*"bank_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
```

**Почему это работает:**
- `grep -o` извлекает только совпадение
- Regex находит `"bank_id": "значение"`
- `sed` вытаскивает только значение из кавычек
- Работает с любыми пробелами вокруг `:`

### Namespace команд

**Формат:** `/plugin-name:command-name`

**Примеры:**
- `/hindsight:init`
- `/hindsight:retain`
- `/hindsight:recall`
- `/hindsight:reflect`

**Важно:**
- ❌ НЕ использовать короткие префиксы типа `/hs:` (неясно)
- ✅ Полное имя плагина для ясности
- ✅ Имя файла команды становится именем команды

---

## 📚 Best Practices

### Разработка команд

1. **Всегда читай файлы перед изменением**
   - Read tool перед Edit/Write
   - Проверяй существующую структуру

2. **Используй ${CLAUDE_PLUGIN_ROOT}**
   - Для всех путей к файлам плагина
   - Обеспечивает портативность
   - Пример: `${CLAUDE_PLUGIN_ROOT}/scripts/init.sh`

3. **Обрабатывай ошибки**
   - Проверяй существование файлов
   - Валидируй входные данные
   - Понятные сообщения об ошибках

4. **Bash execution порядок**
   - Bash команды выполняются **перед** промптом
   - Результаты доступны Claude в промпте
   - Claude интерпретирует результаты для пользователя

### Разработка агентов

1. **Description - самое важное**
   - Однострочный, но может быть длинным
   - Четкие триггеры когда использовать
   - Используй "Use proactively when..."

2. **Минимум инструментов**
   - Давай только необходимые tools
   - Принцип наименьших привилегий
   - Безопасность превыше удобства

3. **Структурированный промпт**
   - Responsibilities - что делать
   - Process - как делать
   - Output - что возвращать
   - Edge cases - как обрабатывать исключения

### Разработка skills

1. **Триггерные слова**
   - Включай в description слова, при которых skill должен активироваться
   - Примеры: "retain", "recall", "memory bank"

2. **Прогрессивное раскрытие**
   - Начинай с общего обзора
   - Затем подробности в секциях
   - Примеры в конце

3. **References подпапка**
   - Для подробной справочной информации
   - CLI команды, API reference и т.д.

### Работа с Git

1. **Git-ignore правила**
   - `.claude/hindsight.json` - игнорируется (персональные настройки)
   - `.claude/hindsight-guide.md` - коммитится (общие инструкции)
   - Скрипты создают .gitignore автоматически

2. **Коммиты**
   - Атомарные изменения
   - Понятные сообщения
   - Co-authored с Claude при необходимости

---

## 🚀 Workflow разработки

### Локальная разработка

1. **Структура:**
   ```
   ~/.claude/plugins/hindsight-marketplace/
   ├── .claude-plugin/marketplace.json
   └── plugins/hindsight/
   ```

2. **Подключение:**
   ```bash
   /plugin marketplace add /Users/dmitriynenashev/.claude/plugins/hindsight-marketplace
   /plugin install hindsight
   ```

3. **Тестирование:**
   - Изменения в плагине
   - Перезапуск Claude Code
   - Проверка команд `/hindsight:*`

### Публикация

1. **GitHub репозиторий:**
   ```bash
   git remote add origin https://github.com/user/hindsight-plugin.git
   git push -u origin main
   ```

2. **Marketplace.json обновление:**
   - Увеличить version в plugin.json
   - Обновить marketplace.json если нужно
   - Коммит и push

3. **Установка из GitHub:**
   ```bash
   /plugin marketplace add user/hindsight-plugin
   /plugin install hindsight@user-hindsight-plugin
   ```

---

## 🐛 Troubleshooting

### Команды не появляются

**Причины:**
1. Plugin не установлен
2. Кэш не обновлен
3. Ошибка в frontmatter команды

**Решение:**
```bash
# Проверить установленные плагины
/plugin list

# Очистить кэш
rm -rf ~/.claude/plugins/cache

# Перезапустить Claude Code
```

### Агент не вызывается автоматически

**Причины:**
1. Description не содержит четких триггеров
2. Контекст не совпадает с description
3. Description слишком сложный (многострочные блоки)

**Решение:**
- Упростить description до однострочного
- Добавить явные триггеры: "Use proactively when..."
- Использовать конкретные ключевые слова

### Скрипты не выполняются

**Причины:**
1. Нет исполняемых прав
2. Неправильный путь (не используется ${CLAUDE_PLUGIN_ROOT})
3. Нет allowed-tools: ["Bash"] в команде

**Решение:**
```bash
# Дать права
chmod +x scripts/*.sh

# Проверить frontmatter команды
# allowed-tools: ["Bash"]

# Использовать правильный путь
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/script.sh`
```

### Hooks не срабатывают

**Причины:**
1. Неправильная структура JSON (нет root key "hooks")
2. Синтаксическая ошибка в JSON
3. Неправильный matcher

**Решение:**
- Проверить структуру: `{"hooks": {"Stop": [...]}}`
- Валидировать JSON: `jq . hooks/hooks.json`
- Использовать пустой matcher для всех событий

---

## 📖 Справочные ресурсы

### Официальная документация

- [Plugin Development](https://code.claude.com/docs/en/discover-plugins)
- [Sub-agents](https://code.claude.com/docs/en/sub-agents)
- [Slash Commands](https://code.claude.com/docs/en/slash-commands)
- [Hooks Guide](https://code.claude.com/docs/en/hooks-guide)

### Внутренние референсы

- `plugins/hindsight/skills/memory-workflow/references/cli-commands.md` - Полный справочник Hindsight CLI
- `plugins/hindsight/README.md` - Описание плагина
- `plugins/hindsight/USAGE.md` - Руководство пользователя

### Примеры из official plugins

В `~/.claude/plugins/marketplaces/claude-plugins-official/` можно найти примеры:
- `plugin-dev` - Создание плагинов
- `commit-commands` - Git workflow команды
- `pr-review-toolkit` - Review агенты

---

## 🎓 Уроки разработки

### Что мы узнали

1. **Конфигурация должна быть простой**
   - ❌ YAML frontmatter в .md файле
   - ✅ Простой JSON файл
   - Легче парсить, меньше ошибок

2. **Разделяй конфиг и инструкции**
   - Конфиг (hindsight.json) - git-ignored, персональный
   - Инструкции (hindsight-guide.md) - git-committed, общий
   - Разные lifecycle, разные файлы

3. **Description агента критичен**
   - Один из самых частых багов - сложный description
   - Должен быть однострочным (но может быть длинным)
   - Без `<example>` блоков в YAML

4. **Frontmatter - только необходимое**
   - ❌ НЕ добавлять `name` в commands
   - ❌ НЕ добавлять `version` в skills
   - ✅ Только поля из официальной схемы

5. **${CLAUDE_PLUGIN_ROOT} обязателен**
   - Для всех путей к файлам плагина
   - Иначе плагин не portable
   - Не забывай в командах!

6. **Bash execution мощный инструмент**
   - Выполняется ДО промпта
   - Можно получить любые данные
   - Claude интерпретирует результаты

---

## 📝 TODO для улучшения плагина

- [ ] Добавить команду `/hindsight:stats` для статистики банка
- [ ] Добавить команду `/hindsight:export` для экспорта воспоминаний
- [ ] Улучшить error handling в скриптах
- [ ] Добавить тесты для bash скриптов
- [ ] Создать GitHub Actions для проверки плагина
- [ ] Написать Contributing guide
- [ ] Добавить примеры использования в USAGE.md
- [ ] Создать видео-демонстрацию

---

_Последнее обновление: 2026-01-19_
_Версия плагина: 1.0.0_
