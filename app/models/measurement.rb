include ActionView::Helpers::DateHelper

class Measurement < ActiveRecord::Base
  belongs_to :instrument

  def self.to_csv(metadata, varnames, options = {})
  
    # Upon entry, we contain the measurements of interest (i.e.
    # they have been time and instrument selected.
    
    # Fetch the desired data. A hash is returned. It contains
    # an entry "Time", with data times, and entries for each of the 
    # varnames.
    vardata = MeasurementsHelper.columnize(self, varnames)
    
    # Get the time values
    times = vardata["Time"].values.sort
    
    # Collect the CSV column titles from varnames
    column_titles = []
    column_titles << "Time"
    varnames.each {|v| column_titles << v[1]}
    
    # Create the csv file, with one column for each var
    CSV.generate(options) do |csv|
      # Put the metadata at the head of the file, one line per group
      metadata.each do |line|
        csv << line
      end
      csv << column_titles
      times.each do |t|
        row = []
        row << t
        varnames.keys.each do |shortname|
          vdata = vardata[shortname]
          # Nil values will create ',,'
          row << vdata[t]
        end
        csv << row
      end
    end
  end

  def self.to_json(varnames)
  
    # Upon entry, we contain the measurements of interest (i.e.
    # they have been time and instrument selected.
    
    # Fetch the desired data. A hash is returned. It contains
    # an entry "Time", with data times, and entries for each of the 
    # varnames.
    vardata = MeasurementsHelper.columnize(self, varnames)

    return vardata.to_json

  end

  def json_point
    time = Time.new(self.created_at.year, self.created_at.month, self.created_at.day, self.created_at.hour, self.created_at.min, self.created_at.sec, "+00:00")
    milliseconds = ((time.to_i) * 1000).to_s

    #create an array and echo to JSON
    ret =[milliseconds.to_i, self.value]
    
    json = ActiveSupport::JSON.encode(ret)
    
    return json    
  end
  
  def age
    time_ago_in_words(self.created_at)
  end
  
end


