class Feature < ActiveRecord::Base

  named_scope :published, {:conditions => {:published => true}, :include => [[:featured_user => :pic], [:writer => :pic]]}
  named_scope :all, {:include => [[:featured_user => :pic], [:writer => :pic]]}

  has_many :featured_tracks, :include => :asset, :order => 'featured_tracks.position'
  has_many :comments, :as => :commentable, :dependent => :destroy, :order => 'created_at DESC'

  belongs_to :writer, :class_name => 'User'
  belongs_to :featured_user, :class_name => 'User'
  
  validates_presence_of :writer, :featured_user
  before_save :create_permalink
  
  
  def body
    BlueCloth::new(self[:body]).to_html
  end
  
  def to_param
    "#{self.permalink}"
  end
  
  # hackish way to add featured tracks quick and dirty w/ csv
  
  def featured_tracks_list
    self.featured_tracks.collect(&:asset_id).join(',')
  end
  
  def featured_tracks_list=(ids)
    self.featured_tracks.destroy_all
    ids.split(',').each_with_index do |id, position|
      self.featured_tracks.create(:asset_id => id.to_i, :position => position)
    end
  end
  
  # The following methods help us keep dry w/ comments
  def name
    "#{self.user.name}'s alonetone feature"
  end
  
  alias :unique_id :id
  alias :user :featured_user
  
  protected
  
  def create_permalink
    self.permalink = User.find(self.featured_user_id).login
  end
  
  def publish
    update_attributes(:published => true, :published_at => Time.now)
  end
end
