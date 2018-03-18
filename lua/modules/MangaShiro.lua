function getinfo()
  mangainfo.url=MaybeFillHost(module.RootURL, url)
  if http.get(mangainfo.url) then
    x=TXQuery.Create(http.document)
    if module.website == 'WestManga' then
      mangainfo.title=x.xpathstring('//div[@class="jdlrs"]/h1')
      mangainfo.coverlink=MaybeFillHost(module.RootURL, x.xpathstring('//div[@class="naru"]/img/@src'))
      mangainfo.authors=x.xpathstring('//div[@class="infozin"]//li[starts-with(.,"Author")]/substring-after(.,":")')
      mangainfo.genres=x.xpathstring('//div[@class="infozin"]//li[starts-with(.,"Genre")]/substring-after(.,":")')
      mangainfo.status=MangaInfoStatusIfPos(x.xpathstring('//div[@class="infozin"]//li[starts-with(.,"Status")]'))
      mangainfo.summary=x.xpathstring('//*[@class="sinopc"]/string-join(.//text(),"")')
    elseif module.website == 'KomikCast' then
      mangainfo.title=x.xpathstring('//div[@class="mangainfo"]/h1')
      mangainfo.coverlink=MaybeFillHost(module.RootURL, x.xpathstring('//div[@class="topinfo"]/img/@src'))
      mangainfo.authors=x.xpathstring('//div[@class="topinfo"]//tr[4]/td')
      mangainfo.genres=x.xpathstring('//div[@class="topinfo"]//tr[5]/td')
      mangainfo.status=MangaInfoStatusIfPos(x.xpathstring('//div[@class="topinfo"]//tr[3]/td'))
      mangainfo.summary=x.xpathstring('//*[@class="sin"]/p/string-join(.//text(),"")')
    else
      mangainfo.title=x.xpathstring('//h1[@itemprop="name"]')
      mangainfo.coverlink=MaybeFillHost(module.RootURL, x.xpathstring('//div[@class="imgdesc"]/img/@src'))
      mangainfo.authors=x.xpathstring('//div[@class="listinfo"]//li[starts-with(.,"Author")]/substring-after(.,":")')
      mangainfo.genres=x.xpathstring('//div[@class="listinfo"]//li[starts-with(.,"Genre")]/substring-after(.,":")')
      mangainfo.status=MangaInfoStatusIfPos(x.xpathstring('//div[@class="listinfo"]//li[starts-with(.,"Status")]'))
      mangainfo.summary=x.xpathstring('//*[@class="desc"]/string-join(.//text(),"")')
    end
    x.xpathhrefall('//div[@class="cl"]//li/span[1]/a', mangainfo.chapterlinks, mangainfo.chapternames)
    InvertStrings(mangainfo.chapterlinks,mangainfo.chapternames)
    return no_error
  else
    return net_problem
  end
end

function getpagenumber()
  task.pagenumber=0
  task.pagelinks.clear()
  if http.get(MaybeFillHost(module.rooturl,url)) then
    if module.website == 'WestManga' then
      TXQuery.Create(http.Document).xpathstringall('//*[@class="lexot"]//img/@src', task.pagelinks)
    else
      TXQuery.Create(http.Document).xpathstringall('//*[@id="readerarea"]//img/@src', task.pagelinks)
    end
    return true
  else
    return false
  end
end

function getnameandlink()
  local dirurl = '/manga-list/'
  if module.website == 'MangaShiro' then dirurl = '/daftar-manga/'
  elseif module.website == 'KomikStation' then dirurl = '/daftar-komik/'
  elseif module.website == 'MangaKid' then dirurl = '/manga-lists/'
  elseif module.website == 'KomikCast' then dirurl = '/daftar-komik/?list'
  end
  if http.get(module.rooturl..dirurl) then
    if module.website == 'KomikStation' then
      TXQuery.Create(http.document).xpathhrefall('//*[@class="daftarkomik"]//a',links,names)
    elseif module.website == 'WestManga' then
      TXQuery.Create(http.document).xpathhrefall('//a[@class="series"]',links,names)
    else
      TXQuery.Create(http.document).xpathhrefall('//*[@class="soralist"]//a',links,names)
    end
    return no_error
  else
    return net_problem
  end
end

function AddWebsiteModule(site, url)
  local m=NewModule()
  m.category='Indonesian'
  m.website=site
  m.rooturl=url
  m.lastupdated='February 21, 2018'
  m.ongetinfo='getinfo'
  m.ongetpagenumber='getpagenumber'
  m.ongetnameandlink='getnameandlink'
  return m
end

function Init()
  AddWebsiteModule('MangaShiro', 'http://mangashiro.net')
  AddWebsiteModule('Subapics', 'http://subapics.com')
  AddWebsiteModule('MangaKita', 'http://www.mangakita.net')
  AddWebsiteModule('Mangavy', 'https://mangavy.com')
  AddWebsiteModule('KomikStation', 'http://www.komikstation.com')
  AddWebsiteModule('MangaKid', 'http://mangakid.net')
  AddWebsiteModule('WestManga', 'http://www.westmanga.info')
  AddWebsiteModule('KomikCast', 'https://komikcast.com')
end
