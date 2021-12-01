/*
 * ucode-transpiler.js - JSDoc plugin to naively transpile ucode into JS.
 *
 * Copyright (C) 2021 Jo-Philipp Wich <jo@mein.io>
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

'use strict';

function skipString(s) {
  let q = s.charAt(0);
  let esc = false;

  for (let i = 1; i < s.length; i++) {
    let c = s.charAt(i);

    if (esc) {
      esc = false;
      continue;
    }
    else if (c == '\\') {
      esc = true;
      continue;
    }
    else if (c == q) {
      // consume regex literal flags
      while (q == '/' && s.charAt(i + 1).match(/[gis]/))
        i++;

      return [ s.substring(0, i + 1), s.substring(i + 1) ];
    }
  }

  throw 'Unterminated string literal';
}

function skipComment(s) {
  let q = s.charAt(1),
      end = (q == '/') ? '\n' : '*/',
      esc = false;

  for (let i = 2; i < s.length; i++) {
    let c = s.charAt(i);

    if (esc) {
      esc = false;
      continue;
    }
    else if (c == '\\') {
      esc = true;
      continue;
    }
    else if (s.substring(i, i + end.length) == end) {
      return [ s.substring(0, i + end.length), s.substring(i + end.length) ];
    }
  }

  if (q == '*')
    throw 'Unterminated multiline comment';

  return [ s, '' ];
}

function escapeString(s) {
  return "'" + s.replace(/[\\\n']/g, '\\$&') + "';";
}

const keywords = [
  'break',
  'case',
  'catch',
  'const',
  'continue',
  'default',
  'delete',
  'elif',
  'else',
  'endfor',
  'endfunction',
  'endif',
  'endwhile',
  'false',
  'for',
  'function',
  'if',
  'in',
  'let',
  'null',
  'return',
  'switch',
  'this',
  'true',
  'try',
  'while'
];

const reserved = [
  'await',
  'class',
  'debugger',
  'enum',
  'export',
  'extends',
  'finally',
  'implements',
  'import',
  'instanceof',
  'interface',
  'new',
  'package',
  'private',
  'protected',
  'public',
  'super',
  'throw',
  'typeof',
  'var',
  'void',
  'with',
  'yield'
];

function Transpiler(s, raw) {
  this.source = s;
  this.offset = 0;
  this.tokens = [];

  if (raw) {
    this.state = 'identify_token';
    this.block = 'block_statement';
  }
  else {
    this.state = 'identify_block';
  }

  let token = null;

  do {
    token = this.parse();

    switch (token.type) {
    case '-}}':
    case '-%}':
    case '}}':
    case '%}':
      if (raw)
        throw 'Unexpected token "' + token.type + '"';

      break;
    }

    this.tokens.push(token);
  }
  while (token.type != 'eof');
}

Transpiler.prototype = {
  parse: function() {
    let m;

    switch (this.state) {
    case 'identify_block':
      m = this.source.match(/^((?:.|\n)*?)((\{[{%#])(?:.|\n)*)$/);

      if (m) {
        switch (m[3]) {
        case '{#':
          this.state = 'block_comment';
          break;

        case '{{':
          this.state = 'block_expression';
          break;

        case '{%':
          this.state = 'block_statement';
          break;
        }

        this.source = m[2];

        return { type: 'text', value: escapeString(m[1]), prefix: '' };
      }
      else if (this.source.length) {
        let t = { type: 'text', value: escapeString(this.source), prefix: '' };

        this.source = '';

        return t;
      }
      else {
        return { type: 'eof', value: '', prefix: '' };
      }

      break;

    case 'block_comment':
      m = this.source.match(/^((?:.|\n)*?#\})((?:.|\n)*)$/);

      if (!m)
        throw 'Unterminated comment block';

      this.source = m[2];
      this.state = 'identify_block';
      this.block = null;

      return {
        type: 'comment',
        value: m[1].replace(/\*\}/g, '*\\}').replace(/^\{##/, '/**').replace(/^\{#/, '/*').replace(/#\}$/, '*/'),
        prefix: ''
      };

    case 'block_expression':
      this.state = 'identify_token';
      this.block = 'expression';
      this.source = this.source.replace(/^\{\{[+-]?/, '');

      return this.parse();

    case 'block_statement':
      this.state = 'identify_token';
      this.block = 'statement';
      this.source = this.source.replace(/^\{%[+-]?/, '');

      return this.parse();

    case 'identify_token':
      let t = this.parsetoken();

      if ((this.block == 'expression' && (t.type == '-}}' || t.type == '}}')) ||
          (this.block == 'statement' && (t.type == '-%}' || t.type == '%}'))) {
        this.state = 'identify_block';
        this.block = null;

        return {
          type: ';',
          value: ';',
          prefix: t.prefix
        };
      }

      if (this.block == 'expression' && t.type == 'eof')
        throw 'Unterminated expression block';

      return t;
    }
  },

  parsetoken: function() {
    let token = this.source.match(/^((?:\s|\n)*)(-[%}]\}|<<=|>>=|===|!==|\.\.\.|\?\.\[|\?\.\(|[%}]\}|\/\*|\/\/|&&|[+&|^\/%*-=!<>]=|--|\+\+|<<|>>|\|\||=>|\?\.|[+=&|[\]\^{}:,~\/>!<%*()?;.'"-]|(\d+(?:\.\d+)?)|(\w+))((?:.|\n)*)$/);
    let rv, r, t;

    if (token) {
      switch (token[2]) {
      case '"':
      case "'":
        r = skipString(token[2] + token[5]);
        rv = r[0];
        t = 'string';
        this.source = r[1];
        break;

      case '//':
      case '/*':
        r = skipComment(token[2] + token[5]);
        rv = r[0];
        t = 'comment';
        this.source = r[1];
        break;

      case '/':
      case '/=':
        if (this.lastToken.match(/[(,=:[!&|?{};]/)) {
          r = skipString(token[2] + token[5]);
          rv = r[0];
          t = 'regexp';
          this.source = r[1];
        }
        else {
          rv = token[2];
          t = token[2];
          this.source = token[5];
        }

        break;

      default:
        this.source = token[5];

        if (token[3]) {
          rv = token[3];

          if (token[3].indexOf('.') != -1)
            t = 'double';
          else
            t = 'number';
        }
        else if (token[4]) {
          rv = token[4];

          if (keywords.indexOf(token[4]) != -1) {
            t = token[4];
          }
          else {
            t = 'label';

            if (reserved.indexOf(token[4]) != -1)
              rv += '_';
          }
        }
        else {
          rv = token[2];
          t = token[2];
        }

        break;
      }

      this.lastToken = token[2];

      return {
        type: t,
        value: rv,
        prefix: token[1]
      };
    }
    else if (this.source.match(/^\s*$/)) {
      rv = this.source;
      this.source = '';

      return {
        type: 'eof',
        value: '',
        prefix: rv
      };
    }
    else {
      throw 'Unrecognized character near [...' + this.source + ']';
    }
  },

  next: function() {
    let idx = this.offset++;

    return this.tokens[Math.min(idx, this.tokens.length - 1)];
  },

  skip_statement: function(tokens, ends) {
    let nest = 0;

    while (true) {
      let token = this.next();

      if (token.type == 'eof') {
        this.offset--;

        break;
      }

      if (nest == 0 && ends.indexOf(token.type) != -1) {
        this.offset--;

        break;
      }

      switch (token.type) {
      case '(':
      case '[':
      case '{':
        nest++;
        break;

      case ')':
      case ']':
      case '}':
        nest--;
        break;
      }

      tokens.push(token);

      if (token.type == ';')
        break;
    }

    return tokens;
  },

  skip_paren: function(tokens) {
    let token = this.next();
    let depth = 0;

    if (token.type != '(')
      throw 'Unexpected token, expected "(", got "' + token.type + '"';

    do {
      tokens.push(token);

      switch (token.type) {
      case '(':
        depth++;
        break;

      case ')':
        depth--;

        if (depth == 0)
          return token;

        break;

      case 'eof':
        throw 'Unexpected EOF';
      }

      token = this.next();
    }
    while (depth != 0);
  },

  assert_token: function(tokens, type) {
    let token = this.next();

    if (token.type != type)
      throw 'Unexpected token, expected "' + type + '", got "' + token.type + '"';

    tokens.push(token);

    return tokens;
  },

  check_token: function(tokens, type) {
    let token = this.next();

    if (token.type != type) {
      this.offset--;

      return false;
    }

    tokens.push(token);

    return true;
  },

  patch: function(tokens, type, value) {
    tokens[tokens.length - 1].type = type;
    tokens[tokens.length - 1].value = (value != null) ? value : type;
  },

  skip_block: function(tokens, ends) {
    while (true) {
      let off = tokens.length;

      if (this.check_token(tokens, 'if')) {
        this.skip_paren(tokens);

        if (this.check_token(tokens, ':')) {
          this.patch(tokens, '{');

          this.skip_block(tokens, ['else', 'elif', 'endif']);

          while (tokens[tokens.length - 1].type == 'elif') {
            let elif = tokens.pop();

            tokens.push(
              { type: '}',    value: '}',    prefix: '' },
              { type: 'else', value: 'else', prefix: elif.prefix },
              { type: 'if',   value: 'if',   prefix: ' ' }
            );

            this.skip_paren(tokens);

            this.assert_token(tokens, ':');
            this.patch(tokens, '{');

            this.skip_block(tokens, ['elif', 'else', 'endif']);
          }

          if (tokens[tokens.length - 1].type == 'else') {
            let else_ = tokens.pop();

            tokens.push(
              { type: '}',    value: '}',    prefix: '' },
              { type: 'else', value: 'else', prefix: else_.prefix },
              { type: '{',    value: '{',    prefix: ' ' }
            );

            this.skip_block(tokens, ['endif']);
          }

          this.patch(tokens, '}');
        }
        else if (this.check_token(tokens, '{')) {
          this.skip_block(tokens, ['}']);

          if (!this.check_token(tokens, 'else'))
            continue;

          if (this.check_token(tokens, '{'))
            this.skip_block(tokens, ['}']);
          else
            this.skip_statement(tokens, ends);
        }
        else {
          this.skip_statement(tokens, ends);
        }
      }
      else if (this.check_token(tokens, 'for')) {
        let cond = [];

        this.skip_paren(cond);

        // Transform `for (x, y in ...)` into `for (x/*, y*/ in ...)`
        if (cond.length > 5 &&
            cond[1].type == 'label' &&
            cond[2].type == ',' &&
            cond[3].type == 'label' &&
            cond[4].type == 'in') {
          cond[2].type = 'comment';
          cond[2].value = '/*' + cond[2].value;
          cond[3].type = 'comment';
          cond[3].value = cond[3].value + '*/';
        }

        // Transform `for (let x, y in ...)` into `for (let x/*, y*/ in ...)`
        else if (cond.length > 6 &&
                 cond[1].type == 'let' &&
                 cond[2].type == 'label' &&
                 cond[3].type == ',' &&
                 cond[4].type == 'label' &&
                 cond[5].type == 'in') {
          cond[3].type = 'comment';
          cond[3].value = '/*' + cond[3].value;
          cond[4].type = 'comment';
          cond[4].value = cond[4].value + '*/';
        }

        tokens.push(...cond);

        if (this.check_token(tokens, ':')) {
          this.patch(tokens, '{');
          this.skip_block(tokens, ['endfor']);
          this.patch(tokens, '}');
        }
        else if (this.check_token(tokens, '{'))
          this.skip_block(tokens, ['}']);
        else
          this.skip_statement(tokens, ends);
      }
      else if (this.check_token(tokens, 'while')) {
        this.skip_paren(tokens);

        if (this.check_token(tokens, ':')) {
          this.patch(tokens, '{');
          this.skip_block(tokens, ['endwhile']);
          this.patch(tokens, '}');
        }
        else if (this.check_token(tokens, '{'))
          this.skip_block(tokens, ['}']);
        else
          this.skip_statement(tokens, ends);
      }
      else if (this.check_token(tokens, 'function')) {
        this.check_token(tokens, 'label');
        this.skip_paren(tokens);

        if (this.check_token(tokens, ':')) {
          this.patch(tokens, '{');
          this.skip_block(tokens, ['endfunction']);
          this.patch(tokens, '}');
        }
        else if (this.check_token(tokens, '{'))
          this.skip_block(tokens, ['}']);
      }
      else if (this.check_token(tokens, 'try')) {
        this.assert_token(tokens, '{');
        this.skip_block(tokens, ['}']);
        this.assert_token(tokens, 'catch');

        // Transform `try { ... } catch { ... }` into `try { ... } catch(e) { ... }`
        if (this.tokens[this.offset].type == '(')
          this.skip_paren(tokens);
        else
          tokens.push(
            { type: '(',     value: '(', prefix: '' },
            { type: 'label', value: 'e', prefix: '' },
            { type: ')',     value: ')', prefix: '' }
          );

        this.assert_token(tokens, '{');
        this.skip_block(tokens, ['}']);
      }
      else if (this.check_token(tokens, 'switch')) {
        this.skip_paren(tokens);
        this.assert_token(tokens, '{');
        this.skip_block(tokens, ['}']);
      }
      else if (this.check_token(tokens, '{')) {
        this.skip_block(tokens, ['}']);
      }
      else if (this.check_token(tokens, 'text')) {
        /* pass */
      }
      else if (this.check_token(tokens, 'comment')) {
        /* pass */
      }
      else {
        this.skip_statement(tokens, ends);
      }

      for (let type of ends)
        if (this.check_token(tokens, type))
          return tokens;

      if (this.check_token([], 'eof'))
        break;
    }

    throw 'Unexpected EOF';
  },

  transpile: function() {
    let tokens = [];

    this.skip_block(tokens, ['eof']);

    return tokens.map(t => t.prefix + t.value).join('');
  }
};

exports.handlers = {
  beforeParse: function(e) {
    let raw = !e.source.match(/\{[{%]/) || e.source.match(/^#!([a-z\/]*)ucode[ \t]+-[A-Z]*R/),
        t = new Transpiler(e.source, raw);

    e.source = t.transpile();
  }
};
