# -*- encoding : utf-8 -*-
#
# Defines methods and extensions for a Monoid::Document
# to support comments for the class including this module
#
module Commentable
  
  def self.included(base)
    base.class_eval do

    embeds_many :comments, as: :commentable, cascade_callbacks: true
    accepts_nested_attributes_for :comment

    field :is_commentable, type: Boolean, default: true

    end # Commentable class_eval
  end

end