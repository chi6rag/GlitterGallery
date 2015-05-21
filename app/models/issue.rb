class Issue < ActiveRecord::Base
  # This is to avoid conflict with the :type attribute
  self.inheritance_column = nil

  enum status: [:open, :closed]

  belongs_to :user
  belongs_to :project

  validates_presence_of :title, :description, :user, :project, :status
  acts_as_taggable
  validate :tag_list_inclusion

  scope :status, -> (value) { where status: statuses[value] }

  # We're using sub_id in routes.
  def to_param
    sub_id.to_s
  end

  # Custom validation for tags. Allows new tags only if user
  # is owner of the project
  def tag_list_inclusion
    validates_presence_of :tag_list
    return if user == project.user
    tag_list.each do |tag|
      errors.add(tag, 'is not valid tag') unless project.tag_list.include?(tag)
    end
  end

  # TODO: make a list of 5 most popular types of issues
  #       people can raise on design projects.
  #
  # TYPES
  # [0] - Bug
  # [1] - Improvement
  #
  # STATUSES
  # [0] - OPEN
  # [1] - CLOSED

  # Closes the issue.
  def close
    self.closed!
  end

  # Reopens the issue.
  def reopen
    self.open!
  end

  def self.type_keys
    { 0 => 'Bug', 1 => 'Improvement' }
  end

  def friendly_text
    "Issue ##{sub_id} of #{project.name}"
  end

  def status_text
    status.upcase
  end

  def show_url
    File.join(project.urlbase, 'issues', sub_id.to_s)
  end

  def sub_id
    (project.issue_ids.index(id) + 1).to_i
  end

  # TODO: Remove this after 267 gets merged.
  def self.find_by_sub_id(sub_id)
    sub_id = sub_id.to_i
    all.each do |i|
      return i if i.sub_id == sub_id
    end
    nil
  end
end
