#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
syntax_test.py — Arquivo de teste de esquema de cores
Cobre: imports, tipos, classes, funções, decorators,
       generators, context managers, exceptions,
       comprehensions, lambdas, type hints, dunder methods
"""

# ── Imports ───────────────────────────────────────────────────────────────────
import os
import sys
import json
import asyncio
from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from typing import (
    Any, Optional, Union, Callable,
    Generator, Iterator, TypeVar, Generic
)
from pathlib import Path
from functools import wraps, lru_cache
from enum import Enum, auto

# ── Constantes ────────────────────────────────────────────────────────────────
VERSION        = "1.0.0"
MAX_RETRIES    = 3
PI             = 3.14159265358979
DEBUG          = False
EMPTY          = None
SUPPORTED_EXTS = {".py", ".js", ".ts", ".css", ".json"}

# ── Tipos e TypeVars ──────────────────────────────────────────────────────────
T = TypeVar("T")
Number = Union[int, float]
Callback = Callable[[str], None]

# ── Enum ──────────────────────────────────────────────────────────────────────
class Status(Enum):
    PENDING  = auto()
    RUNNING  = auto()
    DONE     = auto()
    FAILED   = auto()


class Color(Enum):
    RED   = "#ff0000"
    GREEN = "#00ff00"
    BLUE  = "#0000ff"

# ── Dataclass ─────────────────────────────────────────────────────────────────
@dataclass
class Config:
    host:    str       = "localhost"
    port:    int       = 8080
    debug:   bool      = False
    tags:    list[str] = field(default_factory=list)
    meta:    dict      = field(default_factory=dict)

    def to_dict(self) -> dict:
        return {
            "host":  self.host,
            "port":  self.port,
            "debug": self.debug,
            "tags":  self.tags,
        }

# ── Decorator ─────────────────────────────────────────────────────────────────
def retry(max_attempts: int = 3, exceptions: tuple = (Exception,)):
    """Decorator que retenta a função em caso de exceção."""
    def decorator(func: Callable) -> Callable:
        @wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(1, max_attempts + 1):
                try:
                    return func(*args, **kwargs)
                except exceptions as e:
                    if attempt == max_attempts:
                        raise
                    print(f"[retry] tentativa {attempt}/{max_attempts}: {e}")
        return wrapper
    return decorator


def singleton(cls):
    """Decorator que transforma uma classe em singleton."""
    instances = {}
    @wraps(cls)
    def get_instance(*args, **kwargs):
        if cls not in instances:
            instances[cls] = cls(*args, **kwargs)
        return instances[cls]
    return get_instance

# ── Classe Abstrata ───────────────────────────────────────────────────────────
class BaseProcessor(ABC):
    """Classe base abstrata para processadores."""

    def __init__(self, name: str) -> None:
        self.name   = name
        self.status = Status.PENDING
        self._cache: dict[str, Any] = {}

    @abstractmethod
    def process(self, data: Any) -> Any:
        ...

    @abstractmethod
    def validate(self, data: Any) -> bool:
        ...

    def reset(self) -> None:
        self._cache.clear()
        self.status = Status.PENDING

    def __repr__(self) -> str:
        return f"{self.__class__.__name__}(name={self.name!r}, status={self.status})"

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, BaseProcessor):
            return NotImplemented
        return self.name == other.name

# ── Classe Genérica ───────────────────────────────────────────────────────────
class Stack(Generic[T]):
    """Stack genérica com type hint."""

    def __init__(self) -> None:
        self._items: list[T] = []

    def push(self, item: T) -> None:
        self._items.append(item)

    def pop(self) -> T:
        if self.is_empty():
            raise IndexError("pop em stack vazia")
        return self._items.pop()

    def peek(self) -> T:
        if self.is_empty():
            raise IndexError("peek em stack vazia")
        return self._items[-1]

    def is_empty(self) -> bool:
        return len(self._items) == 0

    def __len__(self) -> int:
        return len(self._items)

    def __iter__(self) -> Iterator[T]:
        yield from reversed(self._items)

# ── Herança e Polimorfismo ────────────────────────────────────────────────────
class TextProcessor(BaseProcessor):

    def __init__(self, name: str, encoding: str = "utf-8") -> None:
        super().__init__(name)
        self.encoding = encoding

    def process(self, data: str) -> str:
        self.status = Status.RUNNING
        result = data.strip().lower()
        self._cache[data] = result
        self.status = Status.DONE
        return result

    def validate(self, data: Any) -> bool:
        return isinstance(data, str) and len(data) > 0

    @property
    def cache_size(self) -> int:
        return len(self._cache)

    @staticmethod
    def normalize(text: str) -> str:
        return " ".join(text.split())

    @classmethod
    def from_config(cls, config: Config) -> "TextProcessor":
        return cls(name=config.host, encoding="utf-8")

# ── Funções com Type Hints ─────────────────────────────────────────────────────
@lru_cache(maxsize=128)
def fibonacci(n: int) -> int:
    """Retorna o n-ésimo número de Fibonacci (memoizado)."""
    if n < 0:
        raise ValueError(f"n deve ser >= 0, recebeu {n}")
    if n <= 1:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)


def flatten(nested: list) -> list:
    """Achata uma lista aninhada recursivamente."""
    result = []
    for item in nested:
        if isinstance(item, list):
            result.extend(flatten(item))
        else:
            result.append(item)
    return result


@retry(max_attempts=3, exceptions=(ValueError, RuntimeError))
def risky_operation(value: int) -> int:
    if value < 0:
        raise ValueError(f"valor negativo: {value}")
    return value * 2

# ── Generator e Iterator ──────────────────────────────────────────────────────
def countdown(n: int) -> Generator[int, None, None]:
    """Generator que conta regressivamente."""
    while n >= 0:
        yield n
        n -= 1


def chunk(lst: list, size: int) -> Generator[list, None, None]:
    """Divide uma lista em pedaços de tamanho `size`."""
    for i in range(0, len(lst), size):
        yield lst[i : i + size]

# ── Context Manager ───────────────────────────────────────────────────────────
class Timer:
    """Context manager para medir tempo de execução."""

    def __init__(self, label: str = "elapsed") -> None:
        self.label   = label
        self.elapsed = 0.0

    def __enter__(self) -> "Timer":
        import time
        self._start = time.perf_counter()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> bool:
        import time
        self.elapsed = time.perf_counter() - self._start
        print(f"[{self.label}] {self.elapsed:.4f}s")
        return False  # não suprime exceções

# ── Async ─────────────────────────────────────────────────────────────────────
async def fetch(url: str, timeout: float = 5.0) -> dict:
    """Simula uma requisição assíncrona."""
    await asyncio.sleep(0.1)
    return {"url": url, "status": 200, "body": "ok"}


async def fetch_all(urls: list[str]) -> list[dict]:
    tasks = [asyncio.create_task(fetch(url)) for url in urls]
    return await asyncio.gather(*tasks)

# ── Comprehensions ────────────────────────────────────────────────────────────
squares     = [x**2 for x in range(10)]
even_sq     = [x**2 for x in range(20) if x % 2 == 0]
matrix      = [[i * j for j in range(1, 6)] for i in range(1, 6)]
word_len    = {word: len(word) for word in ["python", "rust", "go", "zig"]}
unique_vals = {x % 7 for x in range(50)}
lazy_cubes  = (x**3 for x in range(100))

# ── Lambdas e Funções de Alta Ordem ───────────────────────────────────────────
double   = lambda x: x * 2
add      = lambda x, y: x + y
identity = lambda x: x

numbers = [3, 1, 4, 1, 5, 9, 2, 6]
sorted_nums  = sorted(numbers)
reversed_lst = sorted(numbers, key=lambda x: -x)
mapped       = list(map(lambda x: x**2, numbers))
filtered     = list(filter(lambda x: x > 3, numbers))

# ── Exceções Customizadas ─────────────────────────────────────────────────────
class AppError(Exception):
    """Erro base da aplicação."""
    def __init__(self, message: str, code: int = 0) -> None:
        super().__init__(message)
        self.code = code


class NotFoundError(AppError):
    """Recurso não encontrado."""

class ValidationError(AppError):
    """Erro de validação de dados."""

# ── Tratamento de Exceções ────────────────────────────────────────────────────
def safe_divide(a: Number, b: Number) -> Optional[float]:
    try:
        result = a / b
    except ZeroDivisionError:
        print("erro: divisão por zero")
        return None
    except TypeError as e:
        raise ValidationError(f"tipos inválidos: {e}", code=400) from e
    else:
        print(f"resultado: {result}")
        return result
    finally:
        print("operação concluída")

# ── Manipulação de Arquivos ───────────────────────────────────────────────────
def read_json(path: Path) -> dict:
    """Lê um arquivo JSON com tratamento de erros."""
    try:
        with path.open("r", encoding="utf-8") as fh:
            return json.load(fh)
    except FileNotFoundError:
        raise NotFoundError(f"arquivo não encontrado: {path}", code=404)
    except json.JSONDecodeError as e:
        raise ValidationError(f"JSON inválido: {e}", code=422)


def write_json(path: Path, data: dict, indent: int = 2) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as fh:
        json.dump(data, fh, indent=indent, ensure_ascii=False)

# ── Strings e F-strings ───────────────────────────────────────────────────────
name    = "Felipe"
version = 3.11
path    = Path("/home/felipe/dotfiles")

greeting    = f"olá, {name}!"
multi_line  = (
    f"usuário : {name}\n"
    f"versão  : {version:.1f}\n"
    f"caminho : {path}\n"
)
raw_str     = r"regex: \d+\.\d+"
byte_str    = b"bytes: \x00\xff"
padded      = f"{'item':<10} {'valor':>10}"
conditional = f"{'par' if len(name) % 2 == 0 else 'ímpar'}"

# ── Walrus Operator (:=) ──────────────────────────────────────────────────────
data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
if (n := len(data)) > 5:
    print(f"lista grande: {n} elementos")

while chunk_data := data[:3]:
    data = data[3:]

# ── Match / Case (Python 3.10+) ───────────────────────────────────────────────
def handle_status(status: Status) -> str:
    match status:
        case Status.PENDING:
            return "aguardando..."
        case Status.RUNNING:
            return "processando..."
        case Status.DONE:
            return "concluído!"
        case Status.FAILED:
            return "falhou."
        case _:
            return "desconhecido"


def parse_command(command: dict) -> str:
    match command:
        case {"action": "move", "x": x, "y": y}:
            return f"mover para ({x}, {y})"
        case {"action": "resize", "width": w, "height": h}:
            return f"redimensionar para {w}×{h}"
        case {"action": str(action)}:
            return f"ação desconhecida: {action}"
        case _:
            return "comando inválido"

# ── Entrypoint ────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    # classes
    proc = TextProcessor("teste")
    print(proc)
    print(proc.process("  Hello World  "))

    # stack genérica
    stack: Stack[int] = Stack()
    for i in range(5):
        stack.push(i)
    print(list(stack))

    # timer
    with Timer("fibonacci"):
        result = [fibonacci(n) for n in range(30)]
    print(result[:10])

    # generator
    for i in countdown(5):
        print(i, end=" ")
    print()

    # match
    for s in Status:
        print(handle_status(s))

    # async
    urls = ["https://example.com", "https://python.org"]
    responses = asyncio.run(fetch_all(urls))
    print(responses)

    # divisão segura
    safe_divide(10, 2)
    safe_divide(10, 0)