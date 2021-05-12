task scrape: :environment do
    puts 'STARTING SCRAPE...'
  
    require 'open-uri'
  
    search_urls = []
    search_urls.append('https://jobs.lever.co/skillshare')
    search_urls.append("https://jobs.lever.co/stackadapt")
  
    cnt = 0
  
    search_urls.each do |target|
  
        doc = Nokogiri::HTML(URI.open(target))
  
        postings = doc.search('div.posting')
  
        postings.each do |p|
          job_title = p.search('a.posting-title > h5').text
          location = p.search('a.posting-title > div > span')[0].text
          team = p.search('a.posting-title > div > span')[1].text
          url = p.search('a.posting-title')[0]['href']
          doc = Nokogiri::HTML(URI.open(url))
          job_des = doc.at('meta[name="twitter:description"]')['content']
  
          if Job.where(job_title:job_title, location:location, team:team, url:url).count <= 0
            Job.create(
                job_title:job_title,
                team:team,
                job_description:job_des,
                location:location,
                url:url)
  
            puts 'Added: ' + (job_title ? job_title : '')
          else
            puts 'Skipped: ' + (job_title ? job_title : '')
          end
  
          puts "Finished Update Task #{(cnt+1).to_i}"
          cnt += 1
        end
  
    end
  
  end
  