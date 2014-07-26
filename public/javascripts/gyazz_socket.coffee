class GyazzSocket
  
  init: (gb, gd, gt) ->
    @socket = io()
    @gb = gb
    @gd = gd
    @gt = gt

    @socket.on 'pagedata', (res) =>
      # alert "pagedata received... data = #{res.data}"
      if res.wiki == wiki && res.title == title
        _data_old =   res['data'].concat()
        @gb.data    = res.data.concat()
        @gb.datestr = res.date
        @gb.timestamps = res.timestamps
        @gb.refresh()

  getdata: (opts=null, callback=null) =>
    opts = {} if opts == null || typeof opts != 'object'
    if typeof opts.version != 'number' || 0 > opts.version
      opts.version = 0
    @socket.emit 'read',
      wiki:  wiki
      title: title
      opts:  opts

  writedata: (data) ->
    notifyBox.print("saving..", {progress: true}).show(1000) # 本当に書けてるかはわからないが1秒表示
    keywords = []
    data.forEach (line) =>
      keywords = keywords.concat @gt.keywords(line, wiki, title, 0)
    datastr = data.join("\n").replace(/\n+$/,'')+"\n"
    @socket.emit 'write',
      wiki:     wiki
      title:    title
      data:     datastr
      keywords: keywords
  
window.GyazzSocket = GyazzSocket
