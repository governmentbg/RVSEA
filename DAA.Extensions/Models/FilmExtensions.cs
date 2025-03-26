using DAA.Data;
using DAA.Extensions.DateTime;
using DAA.Models.Films;

namespace DAA.Extensions.Models
{
    public static class FilmExtensions
    {
        public static IQueryable<VFilm> FilterBySearchText(this IQueryable<VFilm> query, string searchText)
        {
            return query
                .Where(predicate =>
                    !String.IsNullOrWhiteSpace(searchText)
                    && ((predicate.ArchiveName.Contains(searchText))
                        || (predicate.CountryName != null && predicate.CountryName.Contains(searchText))
                        || (predicate.CountryCode != null && predicate.CountryCode.Contains(searchText))
                        || predicate.InventoryNumber.ToString().Contains(searchText)
                        || (predicate.CreatedByDisplayName != null && predicate.CreatedByDisplayName.Contains(searchText))
                        || (predicate.UpdatedByDisplayName != null && predicate.UpdatedByDisplayName.Contains(searchText))));
        }

        public static IQueryable<FilmPackageDocument> FilterBySearchText(this IQueryable<FilmPackageDocument> query, string searchText)
        {
            return query
                .Where(predicate =>
                    !String.IsNullOrWhiteSpace(searchText)
                    && ((predicate.DocumentType == null || predicate.DocumentType.Text.Contains(searchText))
                        || (predicate.Description == null || predicate.Description.Contains(searchText))));
        }

        public static IQueryable<VFilmCard> FilterBySearchText(this IQueryable<VFilmCard> query, string searchText)
        {
            return query
                .Where(predicate =>
                    !String.IsNullOrWhiteSpace(searchText)
                    && ((predicate.CountryCode != null && predicate.CountryCode.Contains(searchText))
                        || (predicate.InventoryNumber != null && predicate.InventoryNumber.Contains(searchText))
                        || (predicate.Title != null && predicate.Title.Contains(searchText))));
        }

        public static FilmShortModel ToShortModel(this VFilm entity)
        {
            if (entity == null)
            {
                return null;
            }

            FilmShortModel model = new FilmShortModel()
            {
                Id = entity.Id,
                SystemIdentifier = entity.SystemIdentifier,
                IsDraft = entity.IsDraft,
                ArchiveId = entity.ArchiveId,
                ArchiveName = entity.ArchiveName,
                CreatedBy = entity.CreatedBy,
                CreatedByDisplayName = entity.CreatedByDisplayName,
                CreatedOn = entity.CreatedOn.UtcToLocalTime(),
                UpdatedBy = entity.UpdatedBy,
                UpdatedByDisplayName = entity.UpdatedByDisplayName,
                UpdatedOn = entity.UpdatedOn.UtcToLocalTime(),
                Deleted = entity.Deleted,
                InventoryNumber = entity.InventoryNumber.ToString(),
                CountryId = entity.CountryId,
                CountryName = entity.CountryName,
                CountryCode = entity.CountryCode,
            };

            return model;
        }

        public static FilmDisplayModel ToDisplayModel(this VFilm entity)
        {
            if (entity == null)
            {
                return null;
            }

            FilmDisplayModel model = new FilmDisplayModel()
            {
                Id = entity.Id,
                SystemIdentifier = entity.SystemIdentifier,
                IsCurrent = entity.IsDraft.HasValue ? entity.IsDraft.Value : false,
                ReadOnly = false,
                ArchiveId = entity.ArchiveId,
                ArchiveName = entity.ArchiveName,
                CreatedBy = entity.CreatedBy,
                CreatedByDisplayName = entity.CreatedByDisplayName,
                CreatedByUserName = entity.CreatedByUserName,
                CreatedOn = entity.CreatedOn.UtcToLocalTime(),
                UpdatedBy = entity.UpdatedBy,
                UpdatedByDisplayName = entity.UpdatedByDisplayName,
                UpdatedByUserName = entity.UpdatedByUserName,
                UpdatedOn = entity.UpdatedOn.UtcToLocalTime(),
                Deleted = entity.Deleted,

                InventoryNumber = entity.InventoryNumber,
                CountryId = entity.CountryId,
                CountryName = entity.CountryName,
                CountryCode = entity.CountryCode,
                Content = entity.Content,
                FramesCount = entity.FramesCount,
                MicrofilmNegativeRollsCount = entity.MicrofilmNegativeRollsCount,
                MicrofilmNegativeFramesCount = entity.MicrofilmNegativeFramesCount,
                MicrofilmPositiveRollsCount = entity.MicrofilmPositiveRollsCount,
                MicrofilmPositiveFramesCount = entity.MicrofilmPositiveFramesCount,
                PhotoCopy = entity.PhotoCopy,
                DigitalCopy = entity.DigitalCopy,
                Size = entity.Size,
                Other = entity.Other,
                AcceptedOnDay = entity.AcceptedOnDay,
                AcceptedOnMonth = entity.AcceptedOnMonth,
                AcceptedOnYear = entity.AcceptedOnYear,
                Source = entity.Source,
                Notes = entity.Notes,

                PackageAId = entity.PackageAid,
                PackageBId = entity.PackageBid,
            };

            return model;
        }


        public static FilmDraftModel? ToFilmDraftModel(this FilmDraft entity)
        {
            if (entity == null)
            {
                return null;
            }

            FilmDraftModel model = new FilmDraftModel()
            {
                Id = entity.Id,
                SystemIdentifier = entity.SystemIdentifier,
                HasExternalSource = entity.HasExternalSource,
                ExternalIdentifier = entity.ExternalIdentifier,
                ArchiveId = entity.ArchiveId,

                IsCurrent = entity.IsCurrent,
                ReadOnly = entity.ReadOnly,

                InventoryNumber = entity.InventoryNumber,
                CountryId = entity.CountryId,
                FramesCount = entity.FramesCount,
                MicrofilmNegativeRollsCount = entity.MicrofilmNegativeRollsCount,
                MicrofilmNegativeFramesCount = entity.MicrofilmNegativeFramesCount,
                MicrofilmPositiveRollsCount = entity.MicrofilmPositiveRollsCount,
                MicrofilmPositiveFramesCount = entity.MicrofilmPositiveFramesCount,
                PhotoCopy = entity.PhotoCopy,
                DigitalCopy = entity.DigitalCopy,
                Size = entity.Size,
                Other = entity.Other,
                AcceptedOnDay = entity.AcceptedOnDay,
                AcceptedOnMonth = entity.AcceptedOnMonth,
                AcceptedOnYear = entity.AcceptedOnYear,
                Source = entity.Source,
                Content = entity.Content,
                Notes = entity.Notes,

                PackageAId = entity.PackageAid,
                PackageBId = entity.PackageBid,
            };

            return model;
        }

        public static FilmCardDraftModel? ToFilmCardDraftModel(this FilmCardDraft entity)
        {
            if (entity == null)
            {
                return null;
            }

            FilmCardDraftModel model = new FilmCardDraftModel()
            {
                Id = entity.Id,
                SystemIdentifier = entity.SystemIdentifier,
                HasExternalSource = entity.HasExternalSource,
                ExternalIdentifier = entity.ExternalIdentifier,
                FilmSystemIdentifier = entity.FilmSystemIdentifier,

                IsCurrent = entity.IsCurrent,
                ReadOnly = entity.ReadOnly,

                ArchiveId = entity.ArchiveId,
                CountryId = entity.CountryId,
                City = entity.City,
                DocumentsCypher = entity.DocumentsCypher,
                Title = entity.Title,
                ArchiveOriginals = entity.ArchiveOriginals,
                StartDateDay = entity.StartDateDay.HasValue ? entity.StartDateDay.Value : null,
                StartDateMonth = entity.StartDateMonth.HasValue ? entity.StartDateMonth.Value : null,
                StartDateYear = entity.StartDateYear.HasValue ? entity.StartDateYear.Value : null,
                EndDateDay = entity.EndDateDay.HasValue ? entity.EndDateDay.Value : null,
                EndDateMonth = entity.EndDateMonth.HasValue ? entity.EndDateMonth.Value : null,
                EndDateYear = entity.EndDateYear.HasValue ? entity.EndDateYear.Value : null,
                AproximateDate = entity.AproximateDate,
                FilmingExtentId = entity.FilmingExtentId,
                Source = entity.Source,
                InventoryNumber = entity.InventoryNumber,
                FramesCount = entity.FramesCount.HasValue ? entity.FramesCount.Value : null,
                MicrofilmNegativeCount = entity.MicrofilmNegativeCount.HasValue ? entity.MicrofilmNegativeCount.Value : null,
                MicrofilmPositiveCount = entity.MicrofilmPositiveCount.HasValue ? entity.MicrofilmPositiveCount.Value : null,
                PhotoCopy = entity.PhotoCopy,
                DigitalCopy = entity.DigitalCopy,
                Size = entity.Size,
                Other = entity.Other,
                Notes = entity.Notes,
                DocumentsFormat = entity.DocumentsFormat,
                DocumentsCharacteristics = entity.DocumentsCharacteristics,
            };

            return model;
        }

        public static FilmDraft ToDraftEntity(this FilmModel model)
        {
            if (model == null)
            {
                return null;
            }


            FilmDraft entity = new FilmDraft
            {
                SystemIdentifier = model.SystemIdentifier,
                HasExternalSource = false,
                IsCurrent = true,
                ReadOnly = false,
                ArchiveId = model.ArchiveId,
                InventoryNumber = model.InventoryNumber,
                CountryId = model.CountryId,
                FramesCount = model.FramesCount,
                MicrofilmNegativeRollsCount = model.MicrofilmNegativeRollsCount,
                MicrofilmNegativeFramesCount = model.MicrofilmNegativeFramesCount,
                MicrofilmPositiveRollsCount = model.MicrofilmPositiveRollsCount,
                MicrofilmPositiveFramesCount = model.MicrofilmPositiveFramesCount,
                PhotoCopy = model.PhotoCopy,
                DigitalCopy = model.DigitalCopy,
                Size = model.Size,
                Other = model.Other,
                AcceptedOnDay = model.AcceptedOnDay,
                AcceptedOnMonth = model.AcceptedOnMonth,
                AcceptedOnYear = model.AcceptedOnYear,
                Source = model.Source,
                Content = model.Content,
                Notes = model.Notes,
            };

            return entity;
        }

        public static Film ToFilmEntity(this FilmModel model)
        {
            if (model == null)
            {
                return null;
            }


            Film entity = new Film
            {
                SystemIdentifier = model.SystemIdentifier,
                HasExternalSource = false,
                ArchiveId = model.ArchiveId,
                InventoryNumber = model.InventoryNumber,
                CountryId = model.CountryId,
                FramesCount = model.FramesCount,
                MicrofilmNegativeRollsCount = model.MicrofilmNegativeRollsCount,
                MicrofilmNegativeFramesCount = model.MicrofilmNegativeFramesCount,
                MicrofilmPositiveRollsCount = model.MicrofilmPositiveRollsCount,
                MicrofilmPositiveFramesCount = model.MicrofilmPositiveFramesCount,
                PhotoCopy = model.PhotoCopy,
                DigitalCopy = model.DigitalCopy,
                Size = model.Size,
                Other = model.Other,
                AcceptedOnDay = model.AcceptedOnDay,
                AcceptedOnMonth = model.AcceptedOnMonth,
                AcceptedOnYear = model.AcceptedOnYear,
                Source = model.Source,
                Content = model.Content,
                Notes = model.Notes,
            };

            return entity;
        }

        public static FilmCard ToFilmCardEntity(this FilmCardModel model)
        {
            if (model == null)
            {
                return null;
            }


            FilmCard entity = new FilmCard
            {
                SystemIdentifier = model.SystemIdentifier,
                FilmId = model.FilmId,
                FilmSystemIdentifier = model.FilmSystemIdentifier,
                HasExternalSource = false,
                ArchiveId = model.ArchiveId,

                CountryId = model.CountryId,
                City = model.City,
                DocumentsCypher = model.DocumentsCypher,
                Title = model.Title,
                ArchiveOriginals = model.ArchiveOriginals,
                StartDateDay = model.StartDateDay.HasValue ? model.StartDateDay.Value : null,
                StartDateMonth = model.StartDateMonth.HasValue ? model.StartDateMonth.Value : null,
                StartDateYear = model.StartDateYear.HasValue ? model.StartDateYear.Value : null,
                EndDateDay = model.EndDateDay.HasValue ? model.EndDateDay.Value : null,
                EndDateMonth = model.EndDateMonth.HasValue ? model.EndDateMonth.Value : null,
                EndDateYear = model.EndDateYear.HasValue ? model.EndDateYear.Value : null,
                AproximateDate = model.AproximateDate,
                FilmingExtentId = model.FilmingExtentId,
                Source = model.Source,
                InventoryNumber = model.InventoryNumber,
                FramesCount = model.FramesCount.HasValue ? model.FramesCount.Value : null,
                MicrofilmNegativeCount = model.MicrofilmNegativeCount.HasValue ? model.MicrofilmNegativeCount.Value : null,
                MicrofilmPositiveCount = model.MicrofilmPositiveCount.HasValue ? model.MicrofilmPositiveCount.Value : null,
                PhotoCopy = model.PhotoCopy,
                DigitalCopy = model.DigitalCopy,
                Size = model.Size,
                Other = model.Other,
                Notes = model.Notes,
                DocumentsFormat = model.DocumentsFormat,
                DocumentsCharacteristics = model.DocumentsCharacteristics,
            };

            return entity;
        }

        public static FilmCardModel ToFilmCardModel(this FilmCard entity)
        {
            if (entity == null)
            {
                return null;
            }


            FilmCardModel model = new FilmCardModel
            {
                SystemIdentifier = entity.SystemIdentifier,
                //FilmId = entity.FilmId,
                FilmSystemIdentifier = entity.FilmSystemIdentifier,
                HasExternalSource = false,
                ArchiveId = entity.ArchiveId,

                CountryId = entity.CountryId,
                City = entity.City,
                DocumentsCypher = entity.DocumentsCypher,
                Title = entity.Title,
                ArchiveOriginals = entity.ArchiveOriginals,
                StartDateDay = entity.StartDateDay.HasValue ? entity.StartDateDay.Value : null,
                StartDateMonth = entity.StartDateMonth.HasValue ? entity.StartDateMonth.Value : null,
                StartDateYear = entity.StartDateYear.HasValue ? entity.StartDateYear.Value : null,
                EndDateDay = entity.EndDateDay.HasValue ? entity.EndDateDay.Value : null,
                EndDateMonth = entity.EndDateMonth.HasValue ? entity.EndDateMonth.Value : null,
                EndDateYear = entity.EndDateYear.HasValue ? entity.EndDateYear.Value : null,
                AproximateDate = entity.AproximateDate,
                FilmingExtentId = entity.FilmingExtentId,
                Source = entity.Source,
                InventoryNumber = entity.InventoryNumber,
                FramesCount = entity.FramesCount.HasValue ? entity.FramesCount.Value : null,
                MicrofilmNegativeCount = entity.MicrofilmNegativeCount.HasValue ? entity.MicrofilmNegativeCount.Value : null,
                MicrofilmPositiveCount = entity.MicrofilmPositiveCount.HasValue ? entity.MicrofilmPositiveCount.Value : null,
                PhotoCopy = entity.PhotoCopy,
                DigitalCopy = entity.DigitalCopy,
                Size = entity.Size,
                Other = entity.Other,
                Notes = entity.Notes,
                DocumentsFormat = entity.DocumentsFormat,
                DocumentsCharacteristics = entity.DocumentsCharacteristics,
            };

            return model;
        }

        public static FilmDraft CopyEntity(this Film entity)
        {
            if (entity == null)
            {
                return null;
            }

            FilmDraft newEntity = new FilmDraft
            {
                ArchiveId = entity.ArchiveId,
                SystemIdentifier = entity.SystemIdentifier, 
                IsCurrent = true,
                ReadOnly = false,
                HasExternalSource = false,
                InventoryNumber = entity.InventoryNumber,
                CountryId = entity.CountryId,
                FramesCount = entity.FramesCount,
                MicrofilmNegativeRollsCount = entity.MicrofilmNegativeRollsCount,
                MicrofilmNegativeFramesCount = entity.MicrofilmNegativeFramesCount,
                MicrofilmPositiveRollsCount = entity.MicrofilmPositiveRollsCount,
                MicrofilmPositiveFramesCount = entity.MicrofilmPositiveFramesCount,
                PhotoCopy = entity.PhotoCopy,
                DigitalCopy = entity.DigitalCopy,
                Size = entity.Size,
                Other = entity.Other,
                AcceptedOnDay = entity.AcceptedOnDay,
                AcceptedOnMonth = entity.AcceptedOnMonth,
                AcceptedOnYear = entity.AcceptedOnYear,
                Source = entity.Source,
                Content = entity.Content,
                Notes = entity.Notes,
            };

            return newEntity;
        }

        public static FilmCardDraft CopyEntity(this FilmCard entity)
        {
            if (entity == null)
            {
                return null;
            }


            FilmCardDraft draft = new FilmCardDraft
            {
                SystemIdentifier = entity.SystemIdentifier,
                HasExternalSource = false,
                IsCurrent = true,
                ReadOnly = false,
                FilmSystemIdentifier = entity.FilmSystemIdentifier,
                ArchiveId = entity.ArchiveId,
                CountryId = entity.CountryId,
                City = entity.City,
                DocumentsCypher = entity.DocumentsCypher,
                Title = entity.Title,
                ArchiveOriginals = entity.ArchiveOriginals,
                StartDateDay = entity.StartDateDay.HasValue ? entity.StartDateDay.Value : null,
                StartDateMonth = entity.StartDateMonth.HasValue ? entity.StartDateMonth.Value : null,
                StartDateYear = entity.StartDateYear.HasValue ? entity.StartDateYear.Value : null,
                EndDateDay = entity.EndDateDay.HasValue ? entity.EndDateDay.Value : null,
                EndDateMonth = entity.EndDateMonth.HasValue ? entity.EndDateMonth.Value : null,
                EndDateYear = entity.EndDateYear.HasValue ? entity.EndDateYear.Value : null,
                AproximateDate = entity.AproximateDate,
                FilmingExtentId = entity.FilmingExtentId,
                Source = entity.Source,
                InventoryNumber = entity.InventoryNumber,
                FramesCount = entity.FramesCount.HasValue ? entity.FramesCount.Value : null,
                MicrofilmNegativeCount = entity.MicrofilmNegativeCount.HasValue ? entity.MicrofilmNegativeCount.Value : null,
                MicrofilmPositiveCount = entity.MicrofilmPositiveCount.HasValue ? entity.MicrofilmPositiveCount.Value : null,
                PhotoCopy = entity.PhotoCopy,
                DigitalCopy = entity.DigitalCopy,
                Size = entity.Size,
                Other = entity.Other,
                Notes = entity.Notes,
                DocumentsFormat = entity.DocumentsFormat,
                DocumentsCharacteristics = entity.DocumentsCharacteristics,
            };

            return draft;
        }

        public static FilmDraft UpdateEntity(this FilmDraft entity, FilmDraftModel model)
        {
            if (model == null)
            {
                return entity;
            }

            entity.IsCurrent = model.IsCurrent;
            entity.ReadOnly = model.ReadOnly;
            entity.ArchiveId = model.ArchiveId;
            entity.InventoryNumber = model.InventoryNumber;
            entity.CountryId = model.CountryId;
            entity.FramesCount = model.FramesCount;
            entity.MicrofilmNegativeRollsCount = model.MicrofilmNegativeRollsCount;
            entity.MicrofilmNegativeFramesCount = model.MicrofilmNegativeFramesCount;
            entity.MicrofilmPositiveRollsCount = model.MicrofilmPositiveRollsCount;
            entity.MicrofilmPositiveFramesCount = model.MicrofilmPositiveFramesCount;
            entity.PhotoCopy = model.PhotoCopy;
            entity.DigitalCopy = model.DigitalCopy;
            entity.Size = model.Size;
            entity.Other = model.Other;
            entity.AcceptedOnDay = model.AcceptedOnDay;
            entity.AcceptedOnMonth = model.AcceptedOnMonth;
            entity.AcceptedOnYear = model.AcceptedOnYear;
            entity.Source = model.Source;
            entity.Content = model.Content;
            entity.Notes = model.Notes;

            return entity;
        }

        public static Film UpdateEntity(this Film entity, FilmDraft draft)
        {
            if (draft == null)
            {
                return entity;
            }

            entity.ArchiveId = draft.ArchiveId;
            entity.InventoryNumber = draft.InventoryNumber;
            entity.CountryId = draft.CountryId;
            entity.FramesCount = draft.FramesCount;
            entity.MicrofilmNegativeRollsCount = draft.MicrofilmNegativeRollsCount;
            entity.MicrofilmNegativeFramesCount = draft.MicrofilmNegativeFramesCount;
            entity.MicrofilmPositiveRollsCount = draft.MicrofilmPositiveRollsCount;
            entity.MicrofilmPositiveFramesCount = draft.MicrofilmPositiveFramesCount;
            entity.PhotoCopy = draft.PhotoCopy;
            entity.DigitalCopy = draft.DigitalCopy;
            entity.Size = draft.Size;
            entity.Other = draft.Other;
            entity.AcceptedOnDay = draft.AcceptedOnDay;
            entity.AcceptedOnMonth = draft.AcceptedOnMonth;
            entity.AcceptedOnYear = draft.AcceptedOnYear;
            entity.Source = draft.Source;
            entity.Content = draft.Content;
            entity.Notes = draft.Notes;

            return entity;
        }


        public static FilmPackageDocumentDisplayModel ToDisplayModel(this FilmPackageDocument entity)
        {
            if (entity == null)
            {
                return null;
            }

            FilmPackageDocumentDisplayModel model = new FilmPackageDocumentDisplayModel()
            {
                Id = entity.Id,
                PackageId = entity.PackageId,
                DocumentTypeId = entity.DocumentTypeId,
                DocumentTypeName = entity.DocumentType.Text,
                FileId = entity.FileId,
                FilePath = entity.FilePath,
                FileName = entity.FileName,
                FileType = entity.FileType,
                ContentType = entity.ContentType,
                FileSizeInBytes = entity.FileSizeInBytes,
                Description = entity.Description,
                HashCode = entity.HashCode,

            };

            return model;
        }
     
        public static FilmPackageDocumentPublicShortModel ToShortPublicModel(this FilmPackageDocument entity)
        {
            if (entity == null)
            {
                return null;
            }

            FilmPackageDocumentPublicShortModel model = new()
            {
                Id = entity.Id,
                DocumentTypeName = entity.DocumentType.Text,
                Description = entity.Description,
                FileName = entity.FileName,
                FileSizeInBytes = entity.FileSizeInBytes,
            };

            return model;
        }

        public static FilmPackageDocumentShortModel ToShortModel(this FilmPackageDocument entity)
        {
            if (entity == null)
            {
                return null;
            }

            FilmPackageDocumentShortModel model = new FilmPackageDocumentShortModel()
            {
                Id = entity.Id,
                PackageId = entity.PackageId,
                DocumentTypeId = entity.DocumentTypeId,
                DocumentTypeName = entity.DocumentType.Text,
                Description = entity.Description,
                FileName = entity.FileName,
                FileSizeInBytes = entity.FileSizeInBytes,
            };

            return model;
        }

        public static FilmCardDraft ToDraftEntity(this FilmCardModel model)
        {
            if (model == null)
            {
                return null;
            }


            FilmCardDraft entity = new FilmCardDraft
            {
                SystemIdentifier = model.SystemIdentifier,
                HasExternalSource = false,
                IsCurrent = true,
                ReadOnly = false,
                FilmSystemIdentifier = model.FilmSystemIdentifier,
                ArchiveId = model.ArchiveId,
                CountryId = model.CountryId,
                City = model.City,
                DocumentsCypher = model.DocumentsCypher,
                Title = model.Title,
                ArchiveOriginals = model.ArchiveOriginals,
                StartDateDay = model.StartDateDay.HasValue ? model.StartDateDay.Value : null,
                StartDateMonth = model.StartDateMonth.HasValue ? model.StartDateMonth.Value : null,
                StartDateYear = model.StartDateYear.HasValue ? model.StartDateYear.Value : null,
                EndDateDay = model.EndDateDay.HasValue ? model.EndDateDay.Value : null,
                EndDateMonth = model.EndDateMonth.HasValue ? model.EndDateMonth.Value : null,
                EndDateYear = model.EndDateYear.HasValue ? model.EndDateYear.Value : null,
                AproximateDate = model.AproximateDate,
                FilmingExtentId = model.FilmingExtentId,
                Source = model.Source,
                InventoryNumber = model.InventoryNumber,
                FramesCount = model.FramesCount.HasValue ? model.FramesCount.Value : null,
                MicrofilmNegativeCount = model.MicrofilmNegativeCount.HasValue ? model.MicrofilmNegativeCount.Value : null,
                MicrofilmPositiveCount = model.MicrofilmPositiveCount.HasValue ? model.MicrofilmPositiveCount.Value : null,
                PhotoCopy = model.PhotoCopy,
                DigitalCopy = model.DigitalCopy,
                Size = model.Size,
                Other = model.Other,
                Notes = model.Notes,
                DocumentsFormat = model.DocumentsFormat,
                DocumentsCharacteristics = model.DocumentsCharacteristics,
            };

            return entity;
        }

        public static FilmCardDraft UpdateEntity(this FilmCardDraft entity, FilmCardDraftModel model)
        {
            if (model == null)
            {
                return entity;
            }

            entity.IsCurrent = model.IsCurrent;
            entity.ReadOnly = model.ReadOnly;
            entity.FilmSystemIdentifier = model.FilmSystemIdentifier;
            entity.ArchiveId = model.ArchiveId;
            entity.CountryId = model.CountryId;
            entity.City = model.City;
            entity.DocumentsCypher = model.DocumentsCypher;
            entity.Title = model.Title;
            entity.ArchiveOriginals = model.ArchiveOriginals;
            entity.StartDateDay = model.StartDateDay.HasValue ? model.StartDateDay.Value : null;
            entity.StartDateMonth = model.StartDateMonth.HasValue ? model.StartDateMonth.Value : null;
            entity.StartDateYear = model.StartDateYear.HasValue ? model.StartDateYear.Value : null;
            entity.EndDateDay = model.EndDateDay.HasValue ? model.EndDateDay.Value : null;
            entity.EndDateMonth = model.EndDateMonth.HasValue ? model.EndDateMonth.Value : null;
            entity.EndDateYear = model.EndDateYear.HasValue ? model.EndDateYear.Value : null;
            entity.AproximateDate = model.AproximateDate;
            entity.FilmingExtentId = model.FilmingExtentId;
            entity.Source = model.Source;
            entity.InventoryNumber = model.InventoryNumber;
            entity.FramesCount = model.FramesCount.HasValue ? model.FramesCount.Value : null;
            entity.MicrofilmNegativeCount = model.MicrofilmNegativeCount.HasValue ? model.MicrofilmNegativeCount.Value : null;
            entity.MicrofilmPositiveCount = model.MicrofilmPositiveCount.HasValue ? model.MicrofilmPositiveCount.Value : null;
            entity.PhotoCopy = model.PhotoCopy;
            entity.DigitalCopy = model.DigitalCopy;
            entity.Size = model.Size;
            entity.Other = model.Other;
            entity.Notes = model.Notes;
            entity.DocumentsFormat = model.DocumentsFormat;
            entity.DocumentsCharacteristics = model.DocumentsCharacteristics;

            return entity;
        }


        public static FilmCard UpdateEntity(this FilmCard entity, FilmCardDraftModel model)
        {
            if (model == null)
            {
                return entity;
            }

            entity.FilmSystemIdentifier = model.FilmSystemIdentifier;
            entity.ArchiveId = model.ArchiveId;
            entity.CountryId = model.CountryId;
            entity.City = model.City;
            entity.DocumentsCypher = model.DocumentsCypher;
            entity.Title = model.Title;
            entity.ArchiveOriginals = model.ArchiveOriginals;
            entity.StartDateDay = model.StartDateDay.HasValue ? model.StartDateDay.Value : null;
            entity.StartDateMonth = model.StartDateMonth.HasValue ? model.StartDateMonth.Value : null;
            entity.StartDateYear = model.StartDateYear.HasValue ? model.StartDateYear.Value : null;
            entity.EndDateDay = model.EndDateDay.HasValue ? model.EndDateDay.Value : null;
            entity.EndDateMonth = model.EndDateMonth.HasValue ? model.EndDateMonth.Value : null;
            entity.EndDateYear = model.EndDateYear.HasValue ? model.EndDateYear.Value : null;
            entity.AproximateDate = model.AproximateDate;
            entity.FilmingExtentId = model.FilmingExtentId;
            entity.Source = model.Source;
            entity.InventoryNumber = model.InventoryNumber;
            entity.FramesCount = model.FramesCount.HasValue ? model.FramesCount.Value : null;
            entity.MicrofilmNegativeCount = model.MicrofilmNegativeCount.HasValue ? model.MicrofilmNegativeCount.Value : null;
            entity.MicrofilmPositiveCount = model.MicrofilmPositiveCount.HasValue ? model.MicrofilmPositiveCount.Value : null;
            entity.PhotoCopy = model.PhotoCopy;
            entity.DigitalCopy = model.DigitalCopy;
            entity.Size = model.Size;
            entity.Other = model.Other;
            entity.Notes = model.Notes;
            entity.DocumentsFormat = model.DocumentsFormat;
            entity.DocumentsCharacteristics = model.DocumentsCharacteristics;

            return entity;
        }
    
        public static FilmCardShortModel ToShortModel(this VFilmCard entity)
        {
            if (entity == null)
            {
                return null;
            }

            FilmCardShortModel model = new FilmCardShortModel()
            {
                Id = entity.Id,
                SystemIdentifier = entity.SystemIdentifier,
                HasExternalSource = entity.HasExternalSource,
                IsDraft = entity.IsDraft,
                FilmSystemIdentifier = entity.FilmSystemIdentifier,
                InventoryNumber = entity.InventoryNumber,
                CountryId = entity.CountryId,
                CountryCode = entity.CountryCode,
                CountryName = entity.CountryName,
                Title = entity.Title,
                Deleted = entity.Deleted
            };

            return model;
        }

        public static FilmCardShortPublicModel ToShortPublicModel(this VFilmCard entity)
        {
            if (entity == null)
            {
                return null;
            }

            FilmCardShortPublicModel model = new()
            {
                SystemIdentifier = entity.SystemIdentifier,
                HasExternalSource = entity.HasExternalSource,
                FilmSystemIdentifier = entity.FilmSystemIdentifier,
                InventoryNumber = entity.InventoryNumber,
                CountryName = entity.CountryName,
                Title = entity.Title,
            };

            return model;
        }
     
        public static FilmCardPublicDisplayModel ToPublicDisplayModel(this VFilmCard entity)
        {
            if (entity == null)
            {
                return null;
            }

            FilmCardPublicDisplayModel model = new()
            {
                SystemIdentifier = entity.SystemIdentifier,
                FilmSystemIdentifier = entity.FilmSystemIdentifier,
                ArchiveName = entity.ArchiveName,
                CountryName = entity.CountryName,
                City = entity.City,
                DocumentsCypher = entity.DocumentsCypher,
                Title = entity.Title,
                ArchiveOriginals = entity.ArchiveOriginals,
                StartDateDay = entity.StartDateDay,
                StartDateMonth = entity.StartDateMonth,
                StartDateYear = entity.StartDateYear,
                EndDateDay = entity.EndDateDay,
                EndDateMonth = entity.EndDateMonth,
                EndDateYear = entity.EndDateYear,
                AproximateDate = entity.AproximateDate,
                FilmingExtentId = entity.FilmingExtentId,
                FilmingExtentName = entity.FilmingExtentName,
                Source = entity.Source,
                InventoryNumber = entity.InventoryNumber,
                FramesCount = entity.FramesCount,
                MicrofilmNegativeCount = entity.MicrofilmNegativeCount,
                MicrofilmPositiveCount = entity.MicrofilmPositiveCount,
                PhotoCopy = entity.PhotoCopy,
                DigitalCopy = entity.DigitalCopy,
                Size = entity.Size,
                Other = entity.Other,
                Notes = entity.Notes,
                DocumentsFormat = entity.DocumentsFormat,
                DocumentsCharacteristics = entity.DocumentsCharacteristics,
            };

            return model;
        }
        public static FilmCardDisplayModel ToDisplayModel(this VFilmCard entity)
        {
            if (entity == null)
            {
                return null;
            }

            FilmCardDisplayModel model = new FilmCardDisplayModel()
            {
                Id = entity.Id,
                SystemIdentifier = entity.SystemIdentifier,
                FilmSystemIdentifier = entity.FilmSystemIdentifier,
                IsCurrent = entity.IsDraft.HasValue && entity.IsDraft.Value == true ? true : false,
                IsDraft = entity.IsDraft.HasValue && entity.IsDraft.Value == true ? true : false,
                ArchiveId = entity.ArchiveId,
                ArchiveName = entity.ArchiveName,
                CountryId = entity.CountryId,
                CountryName = entity.CountryName,
                CountryCode = entity.CountryCode,
                City = entity.City,
                DocumentsCypher = entity.DocumentsCypher,
                Title = entity.Title,
                ArchiveOriginals = entity.ArchiveOriginals,
                StartDateDay = entity.StartDateDay,
                StartDateMonth = entity.StartDateMonth,
                StartDateYear = entity.StartDateYear,
                EndDateDay = entity.EndDateDay,
                EndDateMonth = entity.EndDateMonth,
                EndDateYear = entity.EndDateYear,
                AproximateDate = entity.AproximateDate,
                FilmingExtentId = entity.FilmingExtentId,
                FilmingExtentName = entity.FilmingExtentName,
                Source = entity.Source,
                InventoryNumber = entity.InventoryNumber,
                FramesCount = entity.FramesCount,
                MicrofilmNegativeCount = entity.MicrofilmNegativeCount,
                MicrofilmPositiveCount = entity.MicrofilmPositiveCount,
                PhotoCopy = entity.PhotoCopy,
                DigitalCopy = entity.DigitalCopy,
                Size = entity.Size,
                Other = entity.Other,
                Notes = entity.Notes,
                DocumentsFormat = entity.DocumentsFormat,
                DocumentsCharacteristics = entity.DocumentsCharacteristics,

                CreatedBy = entity.CreatedBy,
                CreatedByDisplayName = entity.CreatedByDisplayName,
                CreatedByUserName = entity.CreatedByUserName,
                CreatedOn = entity.CreatedOn.UtcToLocalTime(),
                UpdatedBy = entity.UpdatedBy,
                UpdatedByDisplayName = entity.UpdatedByDisplayName,
                UpdatedByUserName = entity.UpdatedByUserName,
                UpdatedOn = entity.UpdatedOn.UtcToLocalTime(),
                Deleted = entity.Deleted,
            };

            return model;
        }


        public static IQueryable<FilmReviewDisplayModel> FilterBySearchText(this IQueryable<FilmReviewDisplayModel> query, string searchText)
        {
            return query
                .Where(predicate =>
                    !String.IsNullOrWhiteSpace(searchText)
                    && (predicate.ReaderName.Contains(searchText)
                        || predicate.CreatedByDisplayName.Contains(searchText)
                        || predicate.Username.Contains(searchText)
                        || predicate.FilmSystemIdentifier.ToString().Contains(searchText)
                        || predicate.FilmInventoryNumber.ToString().Contains(searchText)
                        || predicate.FilmNumber.Contains(searchText)
                        || predicate.CreatedByDisplayName.Contains(searchText)
                        || predicate.UpdatedByDisplayName.Contains(searchText)
                        ));
        }

        public static IQueryable<FilmReaderDisplayModel> FilterBySearchText(this IQueryable<FilmReaderDisplayModel> query, string searchText)
        {
            return query
                .Where(predicate =>
                    !String.IsNullOrWhiteSpace(searchText)
                    && (predicate.CountryName.Contains(searchText)));
        }

    }
}
