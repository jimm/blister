// Generated by CoffeeScript 1.3.3
(function() {
  var $, COLOR_SCHEMES, CONN_HEADERS, bindings, color_scheme_index, connection_row, connection_rows, cycle_colors, f, key, kp, list, list_item, maybe_name, message, val;

  $ = jQuery;

  CONN_HEADERS = "<tr>\n  <th>Input</th>\n  <th>Chan</th>\n  <th>Output</th>\n  <th>Chan</th>\n  <th>Prog</th>\n  <th>Zone</th>\n  <th>Xpose</th>\n  <th>Filter</th>\n</tr>";

  COLOR_SCHEMES = ['default', 'green', 'amber', 'blue'];

  color_scheme_index = 0;

  list_item = function(val, highlighted_value) {
    var classes;
    classes = val === highlighted_value ? "selected reverse-" + COLOR_SCHEMES[color_scheme_index] : '';
    return "<li class=\"" + classes + "\">" + val + "</li>";
  };

  list = function(id, vals, highlighted_value) {
    var lis, val;
    lis = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = vals.length; _i < _len; _i++) {
        val = vals[_i];
        _results.push(list_item(val, highlighted_value));
      }
      return _results;
    })();
    return $('#' + id).html(lis.join("\n"));
  };

  connection_row = function(conn) {
    var key, vals;
    vals = (function() {
      var _i, _len, _ref, _results;
      _ref = ['input', 'input_chan', 'output', 'output_chan', 'pc', 'zone', 'xpose', 'filter'];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        key = _ref[_i];
        _results.push(conn[key]);
      }
      return _results;
    })();
    return "<tr><td>" + (vals.join('</td><td>')) + "</td></tr>";
  };

  connection_rows = function(connections) {
    var conn, rows;
    rows = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = connections.length; _i < _len; _i++) {
        conn = connections[_i];
        _results.push(connection_row(conn));
      }
      return _results;
    })();
    $('#patch').html(CONN_HEADERS + "\n" + rows.join("\n"));
    return set_colors();
  };

  maybe_name = function(data, key) {
    if (data[key]) {
      return data[key]['name'];
    } else {
      return '';
    }
  };

  message = function(str) {
    return $('#message').html(str);
  };

  kp = function(action) {
    return $.getJSON(action, function(data) {
      list('song-lists', data['lists'], data['list']);
      list('songs', data['songs'], maybe_name(data, 'song'));
      list('triggers', data['triggers']);
      if (data['song'] != null) {
        list('song', data['song']['patches'], maybe_name(data, 'patch'));
        if (data['patch'] != null) {
          connection_rows(data['patch']['connections']);
        }
      }
      if (data['message'] != null) {
        return message(data['message']);
      }
    });
  };

  remove_colors = function() {
    if (color_scheme_index >= 0) {
      var base_class;
      base_class = COLOR_SCHEMES[color_scheme_index];
      $('body').removeClass(base_class);
      $('.selected, th, td#appname').removeClass("reverse-" + base_class);
      $('tr, td, th').removeClass("" + base_class + "-border");
    }
  };

  set_colors = function() {
    var base_class;
    base_class = COLOR_SCHEMES[color_scheme_index];
    $('body').addClass(base_class);
    $('.selected, th, td#appname').addClass("reverse-" + base_class);
    return $('tr, td, th').addClass("" + base_class + "-border");
  };

  cycle_colors = function() {
    remove_colors();
    color_scheme_index = (color_scheme_index + 1) % COLOR_SCHEMES.length;
    return set_colors();
  };

  bindings = {
    'j': 'next_patch',
    'down': 'next_patch',
    'k': 'prev_patch',
    'up': 'prev_patch',
    'n': 'next_song',
    'left': 'next_song',
    'p': 'prev_song',
    'right': 'prev_song',
    'esc': 'panic'
  };

  f = function(key, val) {
    return $(document).bind('keydown', key, function() {
      return kp(val);
    });
  };

  for (key in bindings) {
    val = bindings[key];
    f(key, val);
  }

  $(document).bind('keydown', 'c', function() {
    return cycle_colors();
  });

  kp('status');

}).call(this);
