const $ = jQuery
const CONN_HEADERS = ['Input', 'Chan', 'Output', 'Chan', 'Prog', 'Zone', 'Xpose', 'Filter']
const CONN_KEYS = ['input', 'input_chan', 'output', 'output_chan', 'pc', 'zone', 'xpose', 'filter']
const COLOR_SCHEMES = ['default', 'green', 'amber', 'blue']
var color_scheme_index = 0

list_item = (val, highlighted_value) => {
  classes = val == highlighted_value ? `selected reverse-${COLOR_SCHEMES[color_scheme_index]}` : ''
  return `<li class=\"${classes}\">${val}</li>`
}

list = (id, vals, highlighted_value) => {
  let lis = vals.map(val => { return list_item(val, highlighted_value) })
  $('#' + id).html(lis.join("\n"))
}

connection_row = (conn) => {
  let vals = CONN_KEYS.map(key => { return conn[key] })
  return `<tr><td>${vals.join('</td><td>')}</td></tr>`
}

connection_rows = (connections) => {
  rows = connections.map(conn => { return connection_row(conn) })
  $('#patch').html(`<tr><th>${CONN_HEADERS.join("</th><th>")}</th></tr>\n${rows.join("\n")}`)
  set_colors()
}

maybe_name = (data, key) => { return data[key] ? data[key]['name'] : '' }

message = (str) => { $('#message').html(str) }

kp = (action) => {
  $.getJSON(action, (data) => {
    list('song-lists', data['lists'], data['list'])
    list('songs', data['songs'], maybe_name(data, 'song'))
    list('triggers', data['triggers'])

    if (data['song']) {
      list('song', data['song']['patches'], maybe_name(data, 'patch'))
      if (data['patch'])
        connection_rows(data['patch']['connections'])
    }

    if (data['message'])
      message(data['message'])
  })
}

remove_colors = () => {
  if (color_scheme_index >= 0) {
    base_class = COLOR_SCHEMES[color_scheme_index]
    $('body').removeClass(base_class)
    $('.selected, th, td#appname').removeClass(`reverse-${base_class}`)
    $('tr, td, th').removeClass(`${base_class}-border`)
  }
}

set_colors = () => {
  base_class = COLOR_SCHEMES[color_scheme_index]
  $('body').addClass(base_class)
  $('.selected, th, td#appname').addClass(`reverse-${base_class}`)
  $('tr, td, th').addClass(`${base_class}-border`)
}

cycle_colors = () => {
  remove_colors()
  color_scheme_index = (color_scheme_index + 1) % COLOR_SCHEMES.length
  set_colors()
}

help = () => {
  $('#help').toggle()
}

const PM_BINDINGS = {
  'j':     'next_patch',
  'down':  'next_patch',
  'k':     'prev_patch',
  'up':    'prev_patch',
  'n':     'next_song',
  'right': 'next_song',
  'p':     'prev_song',
  'left':  'prev_song',
  'esc':   'panic'
}
for (let key of Object.getOwnPropertyNames(PM_BINDINGS)) {
  $(document).bind('keydown', key, () => { kp(PM_BINDINGS[key]) })
}
const LOCAL_BINDINGS = {
  'c': cycle_colors,
  'h': help
}
for (let key of Object.getOwnPropertyNames(LOCAL_BINDINGS)) {
  $(document).bind('keydown', key, () => { LOCAL_BINDINGS[key]() })
}
$(document).ready(() => { kp('status') })
