const $ = jQuery
const CONN_HEADERS = ['Input', 'Chan', 'Output', 'Chan', 'Prog', 'Zone', 'Xpose', 'Filter']
const CONN_KEYS = ['input', 'input_chan', 'output', 'output_chan', 'prog', 'zone', 'xpose', 'filter']
const COLOR_SCHEMES = ['default', 'green', 'amber', 'blue']
const COLOR_BASE_SELECTORS = 'body, #help, #message'
const COLOR_REVERSE_SELECTORS = '.selected, th, td#appname'
const COLOR_BORDER_SELECTORS = 'tr, td, th'
var color_scheme_index = 0

function list_item(val, highlighted_value) {
  classes = val == highlighted_value ? `selected reverse-${COLOR_SCHEMES[color_scheme_index]}` : ''
  return `<li class=\"${classes}\">${val}</li>`
}

function list(id, vals, highlighted_value) {
  let lis = vals.map(val => { return list_item(val, highlighted_value) })
  $('#' + id).html(lis.join("\n"))
}

function connection_row(conn) {
  let vals = CONN_KEYS.map(key => { return conn[key] })
  return `<tr><td>${vals.join('</td><td>')}</td></tr>`
}

function connection_rows(connections) {
  rows = connections.map(conn => { return connection_row(conn) })
  $('#patch').html(`<tr><th>${CONN_HEADERS.join("</th><th>")}</th></tr>\n${rows.join("\n")}`)
  set_colors()
}

function maybe_name(data, key) {
  return data[key] ? data[key]['name'] : ''
}

function message(str) {
  $('#message-text').html(str)
}

function kp(action) {
  $.getJSON(action, (data) => {
    list('song-lists', data['lists'], data['list'])
    list('songs', data['songs'], maybe_name(data, 'song'))
    list('triggers', data['triggers'])

    if (data['song']) {
      list('song', data['song']['patches'], maybe_name(data, 'patch'))
      if (data['patch'])
        connection_rows(data['patch']['connections'])
    }

    message(data['message'] || '&nbsp;')
  })
}

function remove_colors() {
  if (color_scheme_index >= 0) {
    base_class = COLOR_SCHEMES[color_scheme_index]
    $(COLOR_BASE_SELECTORS).removeClass(base_class)
    $(COLOR_REVERSE_SELECTORS).removeClass(`reverse-${base_class}`)
    $(COLOR_BORDER_SELECTORS).removeClass(`${base_class}-border`)
  }
}

function set_colors() {
  base_class = COLOR_SCHEMES[color_scheme_index]
  $(COLOR_BASE_SELECTORS).addClass(base_class)
  $(COLOR_REVERSE_SELECTORS).addClass(`reverse-${base_class}`)
  $(COLOR_BORDER_SELECTORS).addClass(`${base_class}-border`)
}

function cycle_colors() {
  remove_colors()
  color_scheme_index = (color_scheme_index + 1) % COLOR_SCHEMES.length
  set_colors()
}

function toggle_help() {
  $('#help').toggle()
}

function panic_sent_message() {
  console.log("Panic!")
  message("Panic!")
}

const API_BINDINGS = {
  'j':     'next_patch',
  'down':  'next_patch',
  'k':     'prev_patch',
  'up':    'prev_patch',
  'n':     'next_song',
  'right': 'next_song',
  'p':     'prev_song',
  'left':  'prev_song',
  'N':     'next_song_list',
  'P':     'prev_song_list',
  'esc':   'panic',
  'l':     'load'
}
for (let key of Object.getOwnPropertyNames(API_BINDINGS)) {
  $(document).bind('keydown', key, () => { kp(API_BINDINGS[key]) })
}
const LOCAL_BINDINGS = {
  'c': cycle_colors,
  'h': toggle_help
}
for (let key of Object.getOwnPropertyNames(LOCAL_BINDINGS)) {
  $(document).bind('keydown', key, () => { LOCAL_BINDINGS[key]() })
}
$(document).ready(() => { kp('status') })
