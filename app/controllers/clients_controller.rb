UpHex::Pulse.controllers :clients do
  before do
    Ability::PortfolioPolicy.new(current_ability).apply!
  end

  get '/:id' do

    icons={
        :twitter=>'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACoAAAAiCAYAAAApkEs2AAADMUlEQVRYR+1XXY4hURRGSzyOHUztYMyDhIRWTQhCunoFwwraDlrvgBVgBU0IEkR1JOJBMnoFo3dAQnSENt8RpFDFvaX6QWZuIoU6P9/9zs8912y6kmW+Epym/0CNjtS/yagkSQKYfFqtVqLZbBbwNOE5/Pz8zFsslmyxWBwpmYa8iP9kFvb3GI3H46lyuZxhUTyUga4EMDmAswOcaQNS+Rzh/d18PjdZrdZ76Ccg8wx/eRZ/O6BwlIBCDp8kq/LWQSwWEwGirQKOGFUDTaqv8COygCSZHVA4y8DoIznDSlUqlSyrEWzyD/QELVAq/5eWy2Xu5uZGhF4Jvs6GXwlUhpJPYbQ4mUySsizv5ZVayJGDLxwgdwxDL1utVlMshOyARiKRPJz9OlAawViqXq8XtIxFo9E0FRCLM6UMSMnWajUmkHuhh0NK7pwaMwA7hHD64+OjdMgwAYXeEyejXCD3gIqiaLfZbEM4/HaKHYAqQmaAj7xYLMbIM0kHo8+IEkWCee21p3A4TFXIVb2cTK67AAop2Wg08swolVUfCoXyYOs3DNkpzDxGeGWRSnfNZvNspSvt7hgNBoPU6B/1MMTTPzf2f4LRAc8Gd0ADgYAEIy88ynpksan3Vqsl8Oru5ajf7x/ghPmhgyHNE+gwQgBYANDERUBR+Q4Apdw5Wfm8TpTyyM8HtLgir42jMQ9g6Sik5u/7Ambf2+02d9hpU1pAvwOkA+91TVIn2KIjmastbW2pAbUD5LrxG8zoGE6Fc7OD1iZVJ3yv15sAUBr5DFvY9EOn0+HOTU1Gty9ub28zMG5UXy0AJHelqzZ8Neo8Hg/NiymwSxO5rgX9t+l0Kg4Gg5Pj4jnjTJc7l8sl4PpA1wy6C6lO7BpTF+Wl2O12uU4hNdAngRJA9FWaUdPndqzy/g09U+r1ekMdukcqa6AOh8NOoXG73T76DQfU+EV8pWOVmUFFl8jOZrP0peE+ylFiDk7ozqQ7FzdGX4l9sCgbwaJmMTmdTmKSJv0Enkx9FMbGNExDPv8VALdgNXOUQG+KR6DsOGCIJny6T8n9ft9w9riLyejwXWKPqT1d4sAo3asB+hdZMZdBSejQgwAAAABJRU5ErkJggg==',
        :google=>'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACoAAAAiCAYAAAApkEs2AAADgElEQVRYR+2XW04iQRiFQeHFF9wBzAowMRhFLg3xAkaFsAGcFcAOgFkBrkB55mEGL0Qj4SJEExMirmCcHeCLDygw5zDdxkHaLpoOxsRKKqVNVddX57/U32bTJ2nmT8Jp+gI12lK6FI3FYvZer5cETBTdYTabTf1+36QyFqxWazyfzz9MAj82aDQaTQAqDahCt9s9sFgsJoyBmZmZJJ7bCItD7M/Ozv58fn42HR8f1yYBVNaOBbq7u3uIhXH0wtHREdV8advb207A1RRYjEnM2TcCku8QBt3Z2Ylg/i8qBqUcxWLxzzAEYBNQNqu4wePj43ypVJrI5GMrCogWIJ2EODk5UT3g63mYu3d6epozQlVhRQGAff8FjAYoFU3IvpqB8umpgm5tbfWVDbG56gHD4bAfkFV57vRBAdDG5oOoRpRHz8/PC6OUIiieV2VF987OzqZr+lAopEQ8+aoACIwC3dzcpNlp/gccyD71YILp7Yj2O0S1jb6KloSqb9IPDnSP3+34XVV1PT4rHEx8+fr6Os1agGI2/g+g1MXFxQ9l442NjTTzJ3ocSo50DT2QY+VRZYNgMGhHYs9QMfosehtgLSjtwOjAuACl7/QCqa0bS9FRLwkEAryRWvJvNSgpGQ2pS9FhiLW1tQiUHNxYuOPvqahRAfR6L0MUBaSiKP22BYUlo2EnBuWpJUnKQklWVYObC8rSZ6PlcvlNPaDXLcYChZltnU4nAojv2HABnesVNR34m2lJaW1AS5VKxZDAEgZF0Pih1CE2d2DMoQ5NDSvm9Xr9MHuOeVQuou9RNBvis0KgPp+PNeihLNXe5eWl6rW4uLhom5ubywGUZSHbu/NFXUET1O12M2+yxJtn5d5oNPgJotmgbhWTBhdEvV7/r8jWXDxigibo6uoqzU1FGSgSNhX6tPB4PAksyaLXcDhJD9zrNSKgDBanXDVJ19fXQqA44MBdsG46oCsrKyzZaELmyCRAhb6DsC6LdUxZwmveU11TUfgoC42UHMVtlG7Szc3NuylnaWnJiaxQZamHdOZsNpsTfzdpgvKUy8vLjPiBn2LzNpO5mgtgbpwqYuo3jH6tQ4n6rhCoDEuADJS1yzcQ605G9m9CMb+yepLzbA2Kxq+urj7mZiKwy+XiNxGr+wWAzSuK4Bk/VVpPT08Ht7e3hgG+vF9U+o+eJ2z6L1BBBf4CyMKtMvrEroEAAAAASUVORK5CYII=',
        :facebook=>'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACoAAAAiCAYAAAApkEs2AAADRUlEQVRYR9WYX07bQBCHnT9IvMER2hPUD4CAhMQJgQAhiRvxDj1B2xOUnqDcoPQGLiAlCki2BVKQiKIcgRuQvpOkv7FKZOJZdr2hD1hCK+HMzjffjjfrJIw3ciXeCKfxDPTg4MAajUafE4mEPR6PDYzGa4+Yf4B5HYzfHce5VxU1AW00GkeA+vk/4LhiATjA/wuA7avABqC2bVsY3FeA9JH8BHP1RbYoF/K4BE+w+HuPz9L44hWA1mo1J5lM1mdcZlrKY1lCAkWesJSviKPi5KD1OjHq9yQy+GdnZ7Qq0mt/f99KpVKBUVpB9Orv8/NzWxYYGK1Wq+MZl/0jkjmyZHSfQGnpn/JRkYiVFjkBncXoxcWFcJvb29szYXDhqQjkMQF5EsrnI14NtFKpzGRUBIp5HwC1KJGgDoqqg0dQ5wKE32w2I0Z2dnYsPKCubE5R/HRcsGS7u7vaRqnHRKDhXhQ9A6J4FhTVaxulRK1WizWKe1KjongWtFwu6xgt0GTD4XBweXkZ+XaxLGtxfn7enE5IDxP+9yNkmC2UBd3e3o5ttN1uax1okOsYEN9Cu4CPQtWe+q2trdhGMbku6CmsHob3UWXQUqkU2+jV1ZUWKHJ5sJkPLa2PudSMbm5uxjaKrcd6fHw00un0H1GPwtoH3Df+fS4Ysfl7U/uqOmixWIxtNNxjrutGjOBhUt5HuXj2YSoUCrGNhntMBKq6jyqDonhto7QPep7HGlXdR7l41mg+n9c2CmtC0Klzp+i1ho1nQXO5nLZR+q6+vr6OGM1ms8o9ysWzoBsbG9pGaelFoKo9qgyK6rWNEujNzQ1rVLVHuXjWaCaT0TZKPSoCVe1RZdD19XVto9SjnU4nYnR1dVW5R7l41uja2pq2UVp6EahqjyqDonptowR6e3vLGlXtUS6eNbqysjLAd/eC5gueEFSxR38B9GgajAVdXl4+xTIdyj7M3acevbu7ixhdWlpS7dFPiD+V5Q6OaqZpvpubm6NT+kLc93vEUNwXJhGd5E9emg8/PvjdbjdSJAc9OVMClt6/PUw8eQeXVTnjfR/HPrvf70t/d6I8zw6/YF1Er1K/2Bjp5xbjtUeIuEe7eL1eT7rcYRF/AaDx5lBPPK4KAAAAAElFTkSuQmCC'
    }

    @client=Portfolio.find(params[:id])
    error(403) unless current_ability.can? :read, @client
    @clientevents=[]

    @clientstreams=@client.providers.map{|provider|
      {:categorytype=>provider.name,:categoryicon=>icons[provider.provider_name.to_sym],:id=>provider.id,:metricname=>'metric_name',:average=>7,:rangestart=>4,:rangeend=>10,:sparkline=>[3,5,6,8,6,5,7]}
    }.group_by{|s| [s[:categorytype],s[:categoryicon],s[:id]]}
    render 'clients/show'
  end
end