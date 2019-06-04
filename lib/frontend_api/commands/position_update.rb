module FrontendApi
  module Commands
    module PositionUpdate
    private

      def update_position(model, dataset=model.class.dataset)
        if permitted_attrs[:position] && permitted_attrs[:position] != ''
          return if permitted_attrs[:position].to_i <= 0

          if model.position.nil?
            max_position = dataset.max(:position) || 0
            if permitted_attrs[:position].to_i > max_position
              @attrs[:position] = max_position + 1
            else
              DB.transaction do
                dataset.where(Sequel.lit("position >= #{permitted_attrs[:position]}")).update(position: Sequel[:position] + 1)
              end
            end
          else
            if model.position != permitted_attrs[:position]
              if model.position > permitted_attrs[:position].to_i
                DB.transaction do
                  dataset.where(Sequel.lit("position >= #{permitted_attrs[:position]}")).where(Sequel.lit("position < #{model.position}")).update(position: Sequel[:position] + 1)
                end
              else
                DB.transaction do
                  dataset.where(Sequel.lit("position <= #{permitted_attrs[:position]}")).where(Sequel.lit("position > #{model.position}")).update(position: Sequel[:position] - 1)
                end
              end
              max_position = dataset.exclude(id: model.id).max(:position) || 1
              @attrs[:position] = max_position + 1 if permitted_attrs[:position].to_i > max_position
            end
          end
        else
          max_position = if model.position != permitted_attrs[:position]
            dataset.exclude(id: model.id).max(:position)
          else
            dataset.max(:position)
          end
          @attrs[:position] = max_position ? max_position + 1 : 1
        end
      end

      def destroy_position(model, dataset=model.class.dataset)
        DB.transaction do
          dataset.where(Sequel.lit("position >= #{model.position}")).update(position: Sequel[:position] - 1)
        end
      end
    end
  end
end
