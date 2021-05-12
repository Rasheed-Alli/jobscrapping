class ResumesController < ApplicationController
  before_action :set_resume, only: [:show, :edit, :update, :destroy, ]
  respond_to :html, :json

  # GET /resumes
  # GET /resumes.json
  def index
    redirect_to root_path
    @resumes = Resume.all
  end
  
  def build
    #instance variables for resume fields // best in place 
        if params[:email]
            if !user_signed_in?
                user_exist = User.find_by_email(params[:email])
                if user_exist == nil 
                   @user = User.create :email => params[:email],
                                       :name => params[:name],
                                       :organization => params[:organization],
                                       :account_id => params[:account_id]

                    sign_in @user
                else
                    @user = user_exist
                    sign_in @user
                end
            end 
          end
        @resume = Resume.find_by_user_id(current_user.id)
        
       # if params[:name]
       # @resume.update_attributes(:name => params[:name], 
                        #        :email => params[:email], 
                            #    :phone => params[:phone]) 
       # end
        
       
          
        if params[:school]
        @academic_experience.update_attributes  :user_id              => current_user.id, 
                                                  :resume_id              => @resume.id,
                                                  :resume_field                   => "Academic", 
                                                  :position               => params[:degree] +" in " + params[:major],
                                                  :organization           =>  params[:school],
                                                  :detail1            => params[:gpa],
                                                  :end_date               => params[:graduation_month] + params[:gradyear] 
        end
        
        if params[:subdomain]
          redirect_to guide_path(subdomain: params[:subdomain])
        else
          redirect_to resume_path(@resume.id)
        end
  end
  # GET /resumes/1
  # GET /resumes/1.json
  def show
      if params[:name]
          @resume.update_attributes(:name => params[:name], 
                                  :email => params[:email], 
                                  :phone => params[:phone]) 
      end
      if @resume.jobdescription
        experiences = Experience.where(resume_id: @resume.id)
        reader = experiences.map { |f| [f.industry,f.position,f.detail3,f.detail1, f.detail2] }.join '.'
        @reader = reader.downcase
        words = @resume.jobdescription.split(' ')
        frequency = Hash.new(0)
        words.each { |word| frequency[word.downcase.remove(",","(",")")] += 1 }
        @experiences = Experience.where(resume_id: @resume.id, resume_field:"Work").order("created_at ASC")

        
        puts frequency
        @keywords =  frequency.sort_by { |_, v| -v }.first(20).map(&:first) - ["10","-","•","<p>nosh!","<li>a","<p>","<ul>","</ul>","<li>","corp.",",","the","be","to","of","a","and","in","must","qualifications","applicant",
        "for","i","who","minimum","from","do","&","will","with","about","have","available","until","meet","these","considered","an","you","your","may","are","required",
        "this","such","knotch:**","new","how","can","at","work","excellent","on","want","skills","*","more","by","use","we","is","all","as","that","they", "their",".","experience","or","our","(required)"]
        
      end 
      if params[:resume]
        puts "Replacing experiencess....."
        puts params[:resume][:replace_experience]
        id = params[:resume][:replace_experience]
          experience = Experience.where(id: id).last
          text = params[:resume][:replace_text]
          puts text
          puts "printing field to be updated"
          puts params[:resume][:replace_field]
          
          if params[:resume][:replace_field].to_s == "organization"
            experience.update_attributes(organization: text)
          elsif params[:resume][:replace_field].to_s == "position"
            experience.update_attributes(position: text)
          elsif params[:resume][:replace_field].to_s == "detail1"
            experience.update_attributes(detail1: text) 
          elsif params[:resume][:replace_field].to_s == "detail2"
            experience.update_attributes(detail2: text)
          elsif params[:resume][:replace_field].to_s == "detail3"
            experience.update_attributes(detail3: text)
          end
       end
       
      if @resume.job_task_id
        job_description = JobTask.find(@resume.job_task_id)
          if job_description
            if job_description != nil and @resume.jobdescription == nil
              @resume.update_attributes(jobdescription: job_description.jobdescription)
            end
          end 
      end 
      
         
        old_resume = Resume.where(user_id: @resume.user_id).order("created_at ASC").first
        
      
        
      
        @academic_experience = Experience.where(resume_field: 'Academic', resume_id: @resume.id).order("created_at ASC")[0]
        @academic2_experience = Experience.where(resume_field: 'Academic', resume_id: @resume.id)[1]

        @work_experience = Experience.where(resume_field: 'Work', resume_id: @resume.id).order("created_at ASC")[0]
        @work2_experience = Experience.where(resume_field: 'Work', resume_id: @resume.id).order("created_at ASC")[1]
        @work3_experience = Experience.where(resume_field: 'Work', resume_id: @resume.id).order("created_at ASC")[2]
        
        @leadership_experience = Experience.where(resume_field: 'Leadership', resume_id: @resume.id).order("created_at ASC")[0]
        @leadership2_experience = Experience.where(resume_field: 'Leadership', resume_id: @resume.id).order("created_at ASC")[1]
        
        if @resume.template_name == "MAP" or @resume.template_name == "MAPSport"
          if Experience.where(resume_field: 'Work', resume_id: @resume.id).order("created_at ASC")[3] == nil 
            Experience.create(resume_id: @resume.id , resume_field: 'Work')
            2.times do 
              Experience.create(resume_id: @resume.id , resume_field: 'Leadership')
            end
            
            Experience.create(resume_id: @resume.id , resume_field: 'Honors')
            Experience.create(resume_id: @resume.id , resume_field: 'Additional')
            
            @work4_experience = Experience.where(resume_field: 'Work', resume_id: @resume.id).order("created_at ASC")[3]
            @leadership3_experience = Experience.where(resume_field: 'Leadership', resume_id: @resume.id).order("created_at ASC")[2]
            @leadership4_experience = Experience.where(resume_field: 'Leadership', resume_id: @resume.id).order("created_at ASC")[3]
            @honors_experience = Experience.where(resume_field: 'Honors', resume_id: @resume.id).order("created_at ASC")[0]
            @additional_experience = Experience.where(resume_field: 'Additional', resume_id: @resume.id).order("created_at ASC")[0]
          else 
            @work4_experience = Experience.where(resume_field: 'Work', resume_id: @resume.id).order("created_at ASC")[3]
            @leadership3_experience = Experience.where(resume_field: 'Leadership', resume_id: @resume.id).order("created_at ASC")[2]
            @leadership4_experience = Experience.where(resume_field: 'Leadership', resume_id: @resume.id).order("created_at ASC")[3]
            @honors_experience = Experience.where(resume_field: 'Honors', resume_id: @resume.id).order("created_at ASC")[0]
            @additional_experience = Experience.where(resume_field: 'Additional', resume_id: @resume.id).order("created_at ASC")[0]
          end
        end
        
        if Resume.find_by_id(old_resume)
          update_resume = Resume.find_by_id(old_resume)
          
          old_academic = update_resume.experiences.where(resume_field: "Academic").order("created_at ASC").first
          
          if @academic_experience.position == nil
            @academic_experience.update_attributes(position: old_academic.position )
          end 
          
          if @academic_experience.organization == nil
            @academic_experience.update_attributes(organization: old_academic.organization ) 
          end 
          
          if @academic_experience.detail1 == nil
            @academic_experience.update_attributes(detail1: old_academic.detail1 )
          end 
          
          if @academic_experience.detail2 == nil
            @academic_experience.update_attributes(detail2: old_academic.detail2 )
          end
          
          if @academic_experience.detail3 == nil
            @academic_experience.update_attributes(detail3: old_academic.detail3 )
          end 
          
          if @academic_experience.start_date == nil
            @academic_experience.update_attributes(start_date: old_academic.start_date )
          end 
          
         
          
          
          old_work = update_resume.experiences.where(resume_field: "Work").order("created_at ASC").first
          if @work_experience.position == nil 
            @work_experience.update_attributes(position: old_work.position) 
          end 
          
          if @work_experience.organization == nil 
            @work_experience.update_attributes(organization: old_work.organization )
          end 
          
          if @work_experience.detail1 == nil 
            @work_experience.update_attributes(detail1: old_work.detail1 )
          end 
          
          if @work_experience.detail2 == nil 
            @work_experience.update_attributes(detail2: old_work.detail2 )
          end
          
          if @work_experience.detail3 == nil
            @work_experience.update_attributes(detail3: old_work.detail3 )
          end 
          
          if @work_experience.start_date == nil
            @work_experience.update_attributes(start_date: old_work.start_date )
          end 
          

          old_work2 = update_resume.experiences.where(resume_field: "Work").order("created_at ASC")[1]
          if @work2_experience.position == nil 
            @work2_experience.update_attributes(position: old_work2.position )
          end 
          
          if @work2_experience.organization == nil 
            @work2_experience.update_attributes(organization: old_work2.organization )
          end 
          
          if @work2_experience.detail1 == nil 
            @work2_experience.update_attributes(detail1: old_work2.detail1 )
          end 
          
          if @work2_experience.detail2 == nil 
            @work2_experience.update_attributes(detail2: old_work2.detail2 )
          end
          
          if @work2_experience.detail3 == nil 
            @work2_experience.update_attributes(detail3: old_work2.detail3 )
          end 
          
          if @work2_experience.start_date == nil 
            @work2_experience.update_attributes(start_date: old_work2.start_date )
          end 
          

          
          old_work3 = update_resume.experiences.where(resume_field: "Work").order("created_at ASC")[2]
          if @work3_experience.position == nil 
            @work3_experience.update_attributes(position: old_work3.position )
          end 
          
          if @work3_experience.organization == nil 
            @work3_experience.update_attributes(organization: old_work3.organization )
          end 
          
          if @work3_experience.detail1 == nil 
            @work3_experience.update_attributes(detail1: old_work3.detail1 )
          end 
          
          if @work3_experience.detail2 == nil 
            @work3_experience.update_attributes(detail2: old_work3.detail2 )
          end
          
          if @work3_experience.detail3 == nil 
            @work3_experience.update_attributes(detail3: old_work3.detail3 )
          end 
          
          if @work3_experience.start_date == nil 
            @work3_experience.update_attributes(start_date: old_work3.start_date )
          end 
          

        
        end
        
       
        
        @resume.skills.each_with_index do |skill,index|
          var_name = "@skill_#{index}"  # the '@' is required
          self.instance_variable_set(var_name, @resume.skills.order("created_at ASC")[index])
        end 
        
        if params[:font]
          @resume.update_attributes(font: params[:font])
        end 
        
        if params[:hide]
          experience = Experience.find(params[:hidden_name].to_i)
          experience.update_attributes(is_hidden: params[:hide])
        end
        
        @review = Review.new
        @rnote = Rnote.new
        @rnotes = Rnote.where(resume_id: @resume.id )
        @typo = Typo.new
        @skill = Skill.new

        @skills = Skill.where(resume_id: @resume_id).order("created_at DESC")

        
        @skill1 = @skills[0]
        @skill2 = @skills[1]
        @skill3 = @skills[2]
        @skill4 = @skills[3]
        @skill5 = @skills[4]
        
        
        @user = User.where(id: @resume.user_id).first
  
        @course = Course.where(id: @user.course_id).first
        
        if @resume.jobdescription
          
          words = @resume.jobdescription.split(' ')
          frequency = Hash.new(0)
          words.each { |word| frequency[word.downcase] += 1 }
          @remove_words = [":","--","has","been","then","here","here:","them","10","-","•","<p>nosh!","<li>a","<p>","<ul>","</ul>","<li>","corp.",",","the","be","to","of","a","and","in","must","qualifications","applicant",
        "for","i","who","minimum","from","do","&","will","with","about","have","available","until","meet","these","considered","an","you","your","may","are","required",
        "this","such","what","you're","youre","knotch:**","new","how","can","at","work","excellent","on","want","skills","*","more","by","use","we","is","all","as","that","they", "their",".","experience","or","our","(required)"]
        
          @common_words =  frequency.sort_by { |_, v| -v }.first(30).map(&:first) - @remove_words
    
          
          @resume.update_attributes(keywords: @common_words)
          

          keywords = @resume.keywords.remove('"','"',"[","]").split(",")

          if @resume.synonyms == nil 
            final_hash = {}
              keywords.each do |w|
              #  syn = Dinosaurus.synonyms_of("#{w}")
              #  puts syn
                require('rubymuse')
                syn = Datamuse.words(ml: "#{w.strip}" )
                synonym = syn.collect(&:first)
                syn_hash = synonym.map { |a| [ a[1], w] }.to_h
                puts syn_hash
                final_hash = final_hash.merge(syn_hash)
              end 
             # @resume.update_attributes(synonyms: final_hash)
          end 

        
          @highlight_keywords = @resume.keywords.remove('/','"',',','[',']').split() - @remove_words || nil

        end
        
        experiences = Experience.where(resume_field: "Work")
        bullet1 = experiences.map { |f| [f.detail1,] }.uniq.join ','
        bullet2 = experiences.map { |f| [f.detail2,] }.uniq.join ','
        bullet3 = experiences.map { |f| [f.detail3,] }.uniq.join ','
        @recommendations = (bullet1 + bullet2 + bullet3).delete('●')
        python = "Python, Python ● Django ● Postgresl , Python ● Django ● SQL , Python ● Flask"
        rails = "Ruby on Rails ● Postgresql, Ruby on Rails ● Postgresl ● Redis ● RSpec, Rails ● React.js ● Javascript"
        javascript = "MongoDB ● Express.js ● Angular ● Node.js , Node.js ● Express.js ● React.js ● SQL, Javascript ● Node.js, Vue.js ● Node.js, React Native ● Firebase "
        datascience = "R, R ● Shiny, Python , R ● Shiny ● Python , Python , Python ● Tensorflow , Python ● Keras , Python ● Tensorflow ● Keras "
        
       # @stack = python + rails + javascript + datascience
        #"City of New York, Here to Here, Administration, Children Services"
  

  end

  # GET /resumes/new
  def new
      @resume = Resume.new
      @resumes = Resume.where(user_id: current_user.id).order("created_at ASC")
     
      if params[:commit] == "duplicate"
        @last_resume = @resumes[-1]
        @last_experiences = @last_resume.experiences
        
        @last_experiences.each do |exp|
          new_exp = exp.dup
          new_exp.resume_id = @resume.id
        end


      end
  end

  # GET /resumes/1/edit
  def edit
    
  end
  
  def change_template
    @resume = Resume.find(params[:id])
    @resume.update_attributes(template_name: params[:template_name] )
    puts "Changing resume design"
    
    respond_to do |format|
      if @resume.save
        format.html { redirect_to @resume, notice: 'Resume design was successfully changed.' }
        format.json { render :show, status: :created, location: @resume }
      else
        format.html { render :new }
        format.json { render json: @resume.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def hide_experience
  
  end

  # POST /resumes
  # POST /resumes.json
  def create
    template_resume = Resume.where(user_id: current_user.id).order("created_at ASC").first
    @resume = template_resume.dup
    @resume.update_attributes(resume_params)
    
    

    respond_to do |format|
      if @resume.save
        format.html { redirect_to @resume, notice: 'Resume was successfully created.' }
        format.json { render :show, status: :created, location: @resume }
        format.js {render 'resumes/create'}

      else
        format.html { render :new }
        format.json { render json: @resume.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def home
   
    
  end 
  
  def change_bullet
    
  end
  
  def review
    require 'pdf-reader'
    require 'open-uri'
    require 'nokogiri'
    require 'similar_text'
    require 'carrierwave/orm/activerecord'
    
    if params[:job_description]
      job_description = params[:job_description]
      
    end 


    
    

    numbers = ["one","two","three","four","five", "six", "seven", "eight", "nine", "ten", "hundred", "twenty", "thirty", 
    "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]
    
    @score = 0

  
        

      if params[:email]
          u = User.new(user_params)
          u.name = params[:name]
          u.email = params[:email]

          
          u.save!
          
          u.resumes.first.update_attributes(:attachment => params[:file])
      
        File.open("#{u.resume}", "rb") do |io|
          io = u.resume.url
          @reader = PDF::Reader.new(io)
          puts reader.info
        end
      end
        
        if params[:job_description]
          @similarity = page.text.similar(job_description)
        end
        
    if @reader
      @reader.pages.each do |page|
        puts page.text
        if page.text =~ /\d/  
          @score += 1
        end 
        
        numbers.each do |number| 
          if page.text.include? number
            @score += 1
          end 
        end 
    end 
  end 
      
    
    
  
    
    
  end
  # PATCH/PUT /resumes/1
  # PATCH/PUT /resumes/1.json
  def update
    @resume.update_attributes(resume_params)
    respond_with @resume
  end

  # DELETE /resumes/1
  # DELETE /resumes/1.json
  def destroy
    @resume.destroy
    respond_to do |format|
      format.html { redirect_to resumes_url, notice: 'Resume was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resume
      @resume = Resume.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resume_params
      params.require(:resume).permit(:tags, :attachment, :approval, :hide, :summary, :hidden_name, :replace_experience, :replace_experience_field, :social, :category, :font, :font_size, :linkedin, :resume, :email, :address, :phone, :languages, :activities, 
      :interests, :name, :default, :public,
      :social_github, :social_facebook, :social_twitter, :social_linkedin, :portfolio,
      :industry, :template_name, :jobdescription, :opt_order, :opt_synonym, :opt_ai, :keywords ,:synonyms, :tenses,:job_title)
    
    end
    def user_params
      params.permit(:name, :email , :resume)
    end
    def set_resume_fields
        @academic_experience = Experience.where(resume_field: 'Academic', resume_id: @resume.id)[0]
        @academic2_experience = Experience.where(resume_field: 'Academic', resume_id: @resume.id)[1]

        @work_experience = Experience.where(resume_field: 'Work', resume_id: @resume.id)[0]
        @work2_experience = Experience.where(resume_field: 'Work', resume_id: @resume.id)[1]
        @work3_experience = Experience.where(resume_field: 'Work', resume_id: @resume.id)[2]
        
        @leadership_experience = Experience.where(resume_field: 'Leadership', resume_id: @resume.id)[0]
        @leadership2_experience = Experience.where(resume_field: 'Leadership', resume_id: @resume.id)[1]
      
    end
end
