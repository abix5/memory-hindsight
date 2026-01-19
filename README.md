# Hindsight Plugin for Claude Code

> Интеграция [Hindsight](https://github.com/vectorize-io/hindsight) memory bank с Claude Code для хранения и извлечения решений разработки между сессиями.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Описание

Этот плагин позволяет Claude Code сохранять и вспоминать важные архитектурные решения, технологические выборы, решения багов и другие важные моменты разработки проекта через Hindsight memory bank.

### Основные возможности

- 💾 **Persistent Memory** - Сохранение архитектурных решений, технологических выборов, багов
- 🔍 **Smart Recall** - Поиск прошлых решений с семантическим пониманием
- 🤖 **AI Reflection** - Получение анализа и рекомендаций на основе сохранённого контекста
- ⚡ **Direct CLI Integration** - Команды напрямую выполняют `hindsight` CLI через bash
- 🎯 **Per-Project Banks** - Каждый проект использует свой собственный банк памяти

## Установка

### Требования

- Claude Code ≥ 1.0.33
- Hindsight server (локально в Docker)
- `hindsight` CLI установлен

### Установка CLI

```bash
cargo install hindsight-cli
# или скачать из releases
```

### Установка плагина

#### Из GitHub (рекомендуется)

```bash
# Добавить marketplace
/plugin marketplace add dmitriynenashev/hindsight-marketplace

# Установить плагин
/plugin install hindsight
```

#### Локальная разработка

```bash
# Добавить локальный marketplace
/plugin marketplace add /Users/dmitriynenashev/Projects/hindsight-marketplace

# Установить плагин
/plugin install hindsight
```

## Быстрый старт

### 1. Инициализация проекта

```bash
/hindsight:init
```

Это создаст:
- `.claude/hindsight.json` - конфигурация (git-ignored)
- `.claude/hindsight-guide.md` - инструкции для команды (git-committed)

### 2. Сохранение решений

```bash
/hindsight:retain "We chose PostgreSQL over MongoDB because we need ACID transactions" --context tech-stack
```

### 3. Поиск решений

```bash
/hindsight:recall database decisions
```

### 4. AI анализ

```bash
/hindsight:reflect Should we add caching given our architecture?
```

## Документация

- **[CLAUDE.md](./CLAUDE.md)** - База знаний для разработки плагинов (для contributors)
- **[plugins/hindsight/README.md](./plugins/hindsight/README.md)** - Описание плагина
- **[plugins/hindsight/USAGE.md](./plugins/hindsight/USAGE.md)** - Подробное руководство пользователя

## Структура репозитория

```
hindsight-marketplace/
├── .claude-plugin/
│   └── marketplace.json              # Описание marketplace
├── plugins/
│   └── hindsight/                    # Плагин
│       ├── commands/                 # Slash-команды (/hindsight:*)
│       ├── scripts/                  # Bash скрипты
│       ├── agents/                   # Специализированные агенты
│       ├── skills/                   # Навыки для Claude
│       ├── hooks/                    # Event hooks
│       └── templates/                # Шаблоны файлов
├── CLAUDE.md                         # База знаний разработки
├── README.md                         # Этот файл
└── .gitignore
```

## Разработка

### Локальная настройка

1. Клонировать репозиторий:
   ```bash
   git clone https://github.com/dmitriynenashev/hindsight-marketplace.git
   cd hindsight-marketplace
   ```

2. Установить для разработки:
   ```bash
   /plugin marketplace add $(pwd)
   /plugin install hindsight
   ```

3. Внести изменения в `plugins/hindsight/`

4. Перезапустить Claude Code для применения изменений

### Архитектура плагина

- **Команды** - Используют bash execution для прямого вызова `hindsight` CLI
- **Скрипты** - Парсят конфиг, инициализируют банк памяти
- **Агенты** - Автоматически идентифицируют важные решения для сохранения
- **Skills** - Предоставляют контекст когда использовать память
- **Hooks** - Напоминают сохранить решения перед завершением сессии

Подробнее см. [CLAUDE.md](./CLAUDE.md)

## Contributing

Contributions welcome! См. [CLAUDE.md](./CLAUDE.md) для базы знаний о разработке плагинов.

### Процесс

1. Fork репозитория
2. Создать feature branch (`git checkout -b feature/amazing-feature`)
3. Commit изменения (`git commit -m 'Add amazing feature'`)
4. Push в branch (`git push origin feature/amazing-feature`)
5. Открыть Pull Request

## License

MIT License - see [LICENSE](LICENSE) file for details

## Acknowledgments

- [Hindsight](https://github.com/vectorize-io/hindsight) - Memory bank system
- [Claude Code](https://claude.com/claude-code) - AI-powered development environment
- Anthropic - За создание Claude Code plugin system

## Support

- 📝 [Issues](https://github.com/dmitriynenashev/hindsight-marketplace/issues)
- 📖 [Documentation](./CLAUDE.md)
- 💬 [Discussions](https://github.com/dmitriynenashev/hindsight-marketplace/discussions)

---

Made with ❤️ by [Dmitriy Nenashev](https://github.com/dmitriynenashev)
