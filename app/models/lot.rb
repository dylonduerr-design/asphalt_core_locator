class Lot < ApplicationRecord
  PLANTS = ['PLANT 1', 'PLANT 2'].freeze
  MIX_TYPES = ['P-401', 'P-403', 'PG 64-10'].freeze
  
  # Color mapping for each mix type
  MIX_COLORS = {
    'P-401' => { bg: 'bg-green-50', border: 'border-green-300', text: 'text-green-800', badge: 'bg-green-100' },
    'P-403' => { bg: 'bg-blue-50', border: 'border-blue-300', text: 'text-blue-800', badge: 'bg-blue-100' },
    'PG 64-10' => { bg: 'bg-purple-50', border: 'border-purple-300', text: 'text-purple-800', badge: 'bg-purple-100' }
  }.freeze
  
  has_many :sublots, -> { order(:position) }, dependent: :destroy
  has_many :lanes, through: :sublots
  has_many :core_generations, dependent: :destroy

  validates :lot_number, presence: true
  validates :plant, presence: true, inclusion: { in: PLANTS }
  validates :mix_type, presence: true, inclusion: { in: MIX_TYPES }
  validates :lot_number, uniqueness: { scope: [:plant, :mix_type], message: "already exists for this plant and mix type" }
  
  # Helper method to get color classes for this lot's mix
  def mix_color_classes
    MIX_COLORS[mix_type] || MIX_COLORS['P-401']
  end
  
  # Scope to filter by plant and mix
  scope :for_plant, ->(plant) { where(plant: plant) if plant.present? }
  scope :for_mix, ->(mix_type) { where(mix_type: mix_type) if mix_type.present? }
end
